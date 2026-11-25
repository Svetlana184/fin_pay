import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PasswordChangedSuccessScreen extends StatelessWidget {
  const PasswordChangedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Иллюстрация (скрин 3)
              Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B2F9F).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Растения по бокам
                    Positioned(left: 20, bottom: 20, child: Icon(Icons.eco, size: 60, color: Colors.green.shade300)),
                    Positioned(right: 20, bottom: 20, child: Icon(Icons.eco, size: 60, color: Colors.green.shade300)),
                    Positioned(left: 30, top: 20, child: Icon(Icons.cloud, size: 50, color: Colors.blue.shade100)),
                    Positioned(right: 30, top: 20, child: Icon(Icons.cloud, size: 50, color: Colors.blue.shade100)),

                    // Телефон с галочкой
                    Positioned(
                      left: 60,
                      top: 30,
                      child: Container(
                        width: 80,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF3B2F9F), width: 3),
                        ),
                        child: const Icon(Icons.check_circle, color: Color(0xFF3B2F9F), size: 40),
                      ),
                    ),

                    // Человек со щитом
                    Positioned(
                      right: 50,
                      top: 40,
                      child: Container(
                        width: 90,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B2F9F).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.shield, color: Color(0xFF3B2F9F), size: 60),
                      ),
                    ),

                    // Ключ
                    Positioned(
                      left: 70,
                      bottom: 40,
                      child: Icon(Icons.vpn_key, color: Colors.orange.shade400, size: 40),
                    ),

                    // Замок
                    Positioned(
                      right: 60,
                      bottom: 50,
                      child: Icon(Icons.lock, color: Colors.orange.shade600, size: 40),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                'Change password successfully!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B2F9F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              const Text(
                'You have successfully change password.\nPlease use the new password when Sign in.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
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