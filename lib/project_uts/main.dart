import 'package:flutter/material.dart';

import 'models/app_user.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/app_database.dart';

void main() {
  runApp(const ProjectUtsApp());
}

class ProjectUtsApp extends StatelessWidget {
  const ProjectUtsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const _AppStartupScreen(),
    );
  }
}

class _AppStartupScreen extends StatefulWidget {
  const _AppStartupScreen();

  @override
  State<_AppStartupScreen> createState() => _AppStartupScreenState();
}

// Cek datasebase
class _AppStartupScreenState extends State<_AppStartupScreen> {
  late Future<void> _databaseReady;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _databaseReady = AppDatabase.instance.database.then((_) {});
  }

  void _retryDatabase() {
    setState(() {
      _databaseReady = AppDatabase.instance.database.then((_) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _databaseReady,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _DatabaseErrorScreen(
            error: snapshot.error!,
            onRetry: _retryDatabase,
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = _user;
        if (user == null) {
          return LoginScreen(
            onLogin: (loggedInUser) {
              setState(() => _user = loggedInUser);
            },
          );
        }
        return MainScreen(
          user: user,
          onLogout: () => setState(() => _user = null),
        );
      },
    );
  }
}

// Status login
class _DatabaseErrorScreen extends StatelessWidget {
  const _DatabaseErrorScreen({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storage, size: 56, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Database tidak dapat dibuka.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('$error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
            ],
          ),
        ),
      ),
    );
  }
}
