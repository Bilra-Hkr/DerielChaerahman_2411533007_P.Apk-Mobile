import 'package:flutter/material.dart';

import '../models/transaction_entry.dart';

class DetailTransactionScreen extends StatelessWidget {
  const DetailTransactionScreen({required this.transaction, super.key});

  final TransactionEntry transaction;

  @override
  Widget build(BuildContext context) {
    final amountColor = transaction.isIncome ? Colors.green : Colors.red;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text(
              transaction.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              transaction.formattedAmount,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            const Divider(height: 40, thickness: 2),
            _buildDetailRow(
              'Jenis',
              transaction.isIncome ? 'Pemasukan' : 'Pengeluaran',
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Kategori', transaction.category),
            const SizedBox(height: 16),
            _buildDetailRow('Tanggal', transaction.formattedDate),
            const SizedBox(height: 16),
            // _buildDetailRow('Status', 'Berhasil'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
