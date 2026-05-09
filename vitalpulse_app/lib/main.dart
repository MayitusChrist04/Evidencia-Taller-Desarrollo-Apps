import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const VitalPulseApp());
}

class VitalPulseApp extends StatelessWidget {
  const VitalPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitalPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B5BDB)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginPage(),
    );
  }
}
