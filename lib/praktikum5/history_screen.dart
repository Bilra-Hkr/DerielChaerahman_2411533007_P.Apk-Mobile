import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> transactions = [
      {
        "title": "Makan Siang",
        "date": "25 Okt 2026",
        "amount": -50000,
        "icon": Icons.restaurant,
      },
      {
        "title": "Gaji Bulanan",
        "date": "24 Okt 2026",
        "amount": 5000000,
        "icon": Icons.attach_money,
      },
      {
        "title": "Beli Buku",
        "date": "23 Okt 2026",
        "amount": -120000,
        "icon": Icons.menu_book,
      },
      {
        "title": "Transfer ke Deril",
        "date": "22 Okt 2026",
        "amount": -200000,
        "icon": Icons.swap_horiz,
      },
      {
        "title": "Bonus Proyek",
        "date": "20 Okt 2026",
        "amount": 750000,
        "icon": Icons.card_giftcard,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
        backgroundColor: Colors.amber,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          final bool isIncome = tx["amount"] > 0;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
              child: Icon(
                tx["icon"],
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              tx["title"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(tx["date"]),
            trailing: Text(
              "${isIncome ? '+' : '-'} Rp ${tx["amount"].abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}",
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
