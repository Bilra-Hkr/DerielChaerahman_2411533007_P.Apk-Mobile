import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/transaction_entry.dart';
import '../services/app_database.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({required this.user, super.key});

  final AppUser user;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<TransactionEntry>> _history;

  @override
  void initState() {
    super.initState();
    _history = _loadHistory();
  }

  Future<List<TransactionEntry>> _loadHistory() async {
    return AppDatabase.instance.getTransactions(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<TransactionEntry>>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat riwayat: ${snapshot.error}'),
            );
          }

          final transactions = snapshot.data ?? const <TransactionEntry>[];
          if (transactions.isEmpty) {
            return const Center(child: Text('Belum ada riwayat transaksi.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: transactions.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isIncome = tx.isIncome;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isIncome
                      ? Colors.green[100]
                      : Colors.red[100],
                  child: Icon(
                    isIncome ? Icons.attach_money : Icons.receipt_long,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  tx.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${tx.formattedDate}'),
                trailing: Text(
                  '${isIncome ? '+' : '-'} Rp ${formatCurrency(tx.amount)}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
