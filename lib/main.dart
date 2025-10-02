import 'package:flutter/material.dart';
import 'dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resident Portal',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: DashboardScreen(), // Remove 'const' here
      debugShowCheckedModeBanner: false,
    );
  }
}
