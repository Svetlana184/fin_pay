import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PasswordChangedSuccessScreen extends StatelessWidget {
  const PasswordChangedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Иллюстрация (заглушка)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B2F9F).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 40,
                      top: 40,
                      child: Icon(Icons.shield, size: 80, color: Colors.green.shade100),
                    ),
                    Positioned(
                      right: 30,
                      bottom: 60,
                      child: Icon(Icons.lock_open, size: 60, color: Colors.orange.shade100),
                    ),
                    Container(
                      height: 200,
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B2F9F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF3B2F9F), width: 3),
                      ),
                      child: const Icon(Icons.check_circle, size: 80, color: Color(0xFF3B2F9F)),
                    ),
                    Positioned(
                      right: 60,
                      top: 80,
                      child: Icon(Icons.shield, size: 70, color: const Color(0xFF3B2F9F)),
                    ),
                    Positioned(
                      left: 40,
                      bottom: 40,
                      child: Icon(Icons.vpn_key, size: 50, color: Colors.orange),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Change password successfully!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B2F9F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'You have successfully change password.\nPlease use the new password when Sign in.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B2F9F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Ok',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}