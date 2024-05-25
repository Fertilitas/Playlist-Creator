import 'package:flutter/material.dart';
import 'package:playlist_creator/presentation/dashboard/screen/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DashboardScreen(),
    );
  }
}
