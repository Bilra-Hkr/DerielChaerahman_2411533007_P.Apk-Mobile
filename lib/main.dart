import 'package:flutter/material.dart';
import 'user_registration_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Pendaftaran',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UserRegistrationForm(),
    );
  }
}