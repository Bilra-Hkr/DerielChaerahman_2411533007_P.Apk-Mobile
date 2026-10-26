import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/transaction_entry.dart';
import '../services/app_database.dart';
import 'add_transaction_screen.dart';
import 'detail_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.user,
    required this.onLogout,
    super.key,
  });

  final AppUser user;
  final VoidCallback onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardData> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = _loadData();
  }

  Future<_DashboardData> _loadData() async {
    final database = AppDatabase.instance;
    final values = await Future.wait<Object>([
      database.getBalance(widget.user.id),
      database.getTransactions(widget.user.id),
    ]);
    return _DashboardData(
      balance: values[0] as int,
      transactions: values[1] as List<TransactionEntry>,
    );
  }

  Future<void> _addTransaction() async {
    final transaction = await Navigator.push<TransactionEntry>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(userId: widget.user.id),
      ),
    );
    if (!mounted || transaction == null) return;

    final currentData = await _dashboardData;
    if (!mounted) return;

    final transactions = [...currentData.transactions, transaction]
      ..sort((first, second) {
        final dateComparison = second.date.compareTo(first.date);
        return dateComparison != 0
            ? dateComparison
            : second.id.compareTo(first.id);
      });
    final balanceChange = transaction.isIncome
        ? transaction.amount
        : -transaction.amount;

    setState(() {
      _dashboardData = Future.value(
        _DashboardData(
          balance: currentData.balance + balanceChange,
          transactions: transactions,
        ),
      );
    });
  }

  Future<void> _openTransaction(TransactionEntry transaction) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailTransactionScreen(transaction: transaction),
      ),
    );
  }

  IconData _transactionIcon(TransactionEntry transaction) {
    if (transaction.isIncome) return Icons.attach_money;
    return switch (transaction.category) {
      'Makanan' => Icons.fastfood,
      'Transportasi' => Icons.directions_car,
      'Hiburan' => Icons.movie,
      _ => Icons.receipt_long,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Keuangan'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<_DashboardData>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Data transaksi gagal dimuat.'),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () =>
                          setState(() => _dashboardData = _loadData()),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${widget.user.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildBalanceCard(data.balance),
                const SizedBox(height: 20),
                const Text(
                  'Transaksi Terakhir',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildTransactionList(data.transactions),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(int balance) {
    return Card(
      elevation: 4,
      color: Colors.redAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saldo utama',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '${balance < 0 ? '- ' : ''}Rp ${formatCurrency(balance.abs())}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionEntry> transactions) {
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('Belum ada transaksi.')),
        ),
      );
    }
    return Card(
      elevation: 2,
      child: Column(
        children: [
          for (var index = 0; index < transactions.length; index++) ...[
            if (index > 0) const Divider(height: 1),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: transactions[index].isIncome
                    ? Colors.green
                    : Colors.orange,
                child: Icon(
                  _transactionIcon(transactions[index]),
                  color: Colors.white,
                ),
              ),
              title: Text(transactions[index].title),
              subtitle: Text(
                '${transactions[index].category} • '
                '${transactions[index].formattedDate}',
              ),
              trailing: Text(
                transactions[index].formattedAmount,
                style: TextStyle(
                  color: transactions[index].isIncome
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _openTransaction(transactions[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardData {
  const _DashboardData({required this.balance, required this.transactions});

  final int balance;
  final List<TransactionEntry> transactions;
}
