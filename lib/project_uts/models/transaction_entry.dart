class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
  });

  final int id;
  final int userId;
  final String title;
  final int amount;
  final String category;
  final DateTime date;
  final bool isIncome;

  factory TransactionEntry.fromMap(Map<String, Object?> map) {
    return TransactionEntry(
      id: map['id']! as int,
      userId: map['user_id']! as int,
      title: map['title']! as String,
      amount: map['amount']! as int,
      category: map['category']! as String,
      date: DateTime.parse(map['date']! as String),
      isIncome: (map['is_income']! as int) == 1,
    );
  }

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  String get formattedAmount =>
      '${isIncome ? '+' : '-'} Rp ${formatCurrency(amount)}';
}

String formatCurrency(int amount) {
  return amount.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
