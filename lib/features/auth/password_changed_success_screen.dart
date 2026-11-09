import 'package:flutter/material.dart';
import 'sign_in_screen.dart';

class PasswordChangedSuccessScreen extends StatelessWidget {
  const PasswordChangedSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Иллюстрация успеха
              Expanded(
                flex: 2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Декоративные элементы
                    Positioned(
                      left: 20,
                      top: 40,
                      child: Icon(Icons.shield, size: 80, color: Colors.green.shade100),
                    ),
                    Positioned(
                      right: 30,
                      bottom: 60,
                      child: Icon(Icons.lock_open, size: 60, color: Colors.orange.shade100),
                    ),
                    // Телефон с галочкой
                    Container(
                      height: 250,
                      width: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A11CB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF6A11CB), width: 3),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Color(0xFF6A11CB),
                      ),
                    ),
                    // Щит
                    Positioned(
                      right: 60,
                      top: 80,
                      child: Icon(Icons.shield, size: 70, color: const Color(0xFF6A11CB)),
                    ),
                    // Ключ
                    Positioned(
                      left: 40,
                      bottom: 40,
                      child: Icon(Icons.vpn_key, size: 50, color: Colors.orange),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Заголовок успеха
              const Text(
                'Change password successfully!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A11CB),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Описание
              const Text(
                'You have successfully change password.\nPlease use the new password when Sign in.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Кнопка OK
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A11CB),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ok',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}