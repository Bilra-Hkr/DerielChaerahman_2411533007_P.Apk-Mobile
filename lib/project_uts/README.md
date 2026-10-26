# Expense Tracker Praktikum 1-5

Hasil praktikum Flutter 1-5 digabung menjadi satu aplikasi Expense Tracker.
Entry point aplikasi terpadu adalah `lib/praktikum5/main.dart`. File ini memang
terpisah dari entry point contoh praktikum lain.

## Fitur

- Registrasi dan login akun dengan data yang disimpan di SQLite lokal.
- Setiap akun memiliki daftar transaksi dan saldo masing-masing.
- Tambah transaksi pemasukan atau pengeluaran dengan kategori dan tanggal.
- Dashboard dan detail transaksi mengambil data yang tersimpan, bukan data
  contoh sementara.
- Tampilan dashboard, form transaksi, dan detail mempertahankan pola UI
  praktikum sebelumnya; login/register merupakan halaman tambahan.

## Menjalankan

```bash
flutter pub get
flutter run -t lib/praktikum5/main.dart
```

Database `praktikum5_expense_tracker.db` dibuat di direktori database
platform saat aplikasi pertama kali dibuka. Android/iOS/macOS menggunakan
plugin SQLite platform; Windows/Linux menggunakan `sqflite_common_ffi`.

Struktur project:

- `lib/praktikum5/models/`: model akun dan transaksi.
- `lib/praktikum5/services/app_database.dart`: skema dan operasi SQLite.
- `lib/praktikum5/screens/`: login, register, dashboard, form transaksi, dan
  detail transaksi.
