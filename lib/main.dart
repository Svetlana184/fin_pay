import 'package:flutter/material.dart';
import 'router/app_router.dart';

void main() {
  runApp(const FinPayApp());
}

class FinPayApp extends StatelessWidget {
  const FinPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FinPay',
      theme: ThemeData(
        primaryColor: const Color(0xFF3B2F9F),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B2F9F)),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}