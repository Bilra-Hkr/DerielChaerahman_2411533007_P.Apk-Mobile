import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/app_user.dart';
import '../models/transaction_entry.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databasePath = path.join(
      await getDatabasesPath(),
      'praktikum5_expense_tracker.db',
    );
    _database = await openDatabase(
      databasePath,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            username TEXT NOT NULL COLLATE NOCASE UNIQUE,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password_salt TEXT NOT NULL,
            password_hash TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            amount INTEGER NOT NULL CHECK (amount > 0),
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            is_income INTEGER NOT NULL CHECK (is_income IN (0, 1)),
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          final tables = await db.query(
            'sqlite_master',
            columns: ['name'],
            where: 'type = ?',
            whereArgs: ['table'],
          );
          final hasUsers = tables.any((row) => row['name'] == 'users');
          if (hasUsers) {
            final columns = await db.rawQuery('PRAGMA table_info(users)');
            final hasUsername =
                columns.any((column) => column['name'] == 'username');
            if (!hasUsername) {
              await db.execute('ALTER TABLE users ADD COLUMN username TEXT');
              final users = await db.query('users');
              for (final user in users) {
                final name = (user['name'] as String).trim();
                final baseUsername = name
                    .toLowerCase()
                    .replaceAll(RegExp(r'\s+'), '_');
                String username = baseUsername;
                for (var i = 1;; i++) {
                  final duplicateUsername = await db.query(
                    'users',
                    where: 'username = ? AND id != ?',
                    whereArgs: [username, user['id']],
                    limit: 1,
                  );
                  if (duplicateUsername.isEmpty) {
                    break;
                  }
                  username = '${baseUsername}_$i';
                }
                await db.update(
                  'users',
                  {'username': username},
                  where: 'id = ?',
                  whereArgs: [user['id']],
                );
              }
            }
          }
        }
      },
    );
    return _database!;
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    final db = await database;
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedUsername = username.trim();

    final emailExists = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (emailExists.isNotEmpty) {
      throw const AuthException('Email sudah terdaftar.');
    }

    final usernameExists = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [normalizedUsername],
      limit: 1,
    );
    if (usernameExists.isNotEmpty) {
      throw const AuthException('Username sudah dipakai.');
    }

    final salt = _newSalt();
    final id = await db.insert('users', {
      'name': name.trim(),
      'username': normalizedUsername,
      'email': normalizedEmail,
      'password_salt': salt,
      'password_hash': _hashPassword(salt, password),
    });
    return AppUser(
      id: id,
      name: name.trim(),
      username: normalizedUsername,
      email: normalizedEmail,
    );
  }

  Future<AppUser?> login({
    required String identifier,
    required String password,
  }) async {
    final db = await database;
    final normalizedIdentifier = identifier.trim();
    final rows = await db.query(
      'users',
      where: 'email = ? OR username = ?',
      whereArgs: [normalizedIdentifier.toLowerCase(), normalizedIdentifier],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    final salt = row['password_salt']! as String;
    if (_hashPassword(salt, password) != row['password_hash']) return null;

    return AppUser(
      id: row['id']! as int,
      name: row['name']! as String,
      username: row['username']! as String,
      email: row['email']! as String,
    );
  }

  Future<List<TransactionEntry>> getTransactions(int userId) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(TransactionEntry.fromMap).toList();
  }

  Future<int> getBalance(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(CASE WHEN is_income = 1 THEN amount ELSE -amount END), 0)
      AS balance
      FROM transactions
      WHERE user_id = ?
      ''',
      [userId],
    );
    return result.first['balance']! as int;
  }

  Future<TransactionEntry> addTransaction({
    required int userId,
    required String title,
    required int amount,
    required String category,
    required DateTime date,
    required bool isIncome,
  }) async {
    final db = await database;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final id = await db.insert('transactions', {
      'user_id': userId,
      'title': title.trim(),
      'amount': amount,
      'category': category,
      'date': normalizedDate.toIso8601String(),
      'is_income': isIncome ? 1 : 0,
    });
    return TransactionEntry(
      id: id,
      userId: userId,
      title: title.trim(),
      amount: amount,
      category: category,
      date: normalizedDate,
      isIncome: isIncome,
    );
  }

  String _newSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String salt, String password) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
