import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 1; // 1 = телефон, 2 = OTP, 3 = новый пароль
  String _phone = '';
  String _sentOtp = '';
  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool get _canSend => _phoneController.text.trim().length >= 10;
  bool get _canChange =>
      _codeController.text.trim().length == 4 &&
          _newPasswordController.text.length >= 6 &&
          _newPasswordController.text == _confirmPasswordController.text;

  Future<void> _onSend() async {
    if (!_canSend) return;
    setState(() {
      _phone = _phoneController.text.trim();
      _loading = true;
    });
    try {
      final result = await _authService.forgotPassword(phone: _phone);
      if (result['success'] == true) {
        setState(() {
          _sentOtp = result['otp'] ?? '123456';
          _step = 2;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP код: $_sentOtp (демо)'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Ошибка'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onResend() async {
    await _onSend();
  }

  Future<void> _onChangePassword() async {
    if (!_canChange) return;
    setState(() => _loading = true);
    try {
      final result = await _authService.resetPassword(
        phone: _phone,
        otp: _codeController.text.trim(),
        newPassword: _newPasswordController.text,
      );
      if (result['success'] == true) {
        if (mounted) context.go('/password-changed');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Ошибка'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _backToPhone() {
    setState(() {
      _step = 1;
      _codeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Forgot password',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: _buildCurrentStep(),
            ),
            if (_step == 2) ...[
              const SizedBox(height: 32),
              TextButton(
                onPressed: _backToPhone,
                child: const Text('Change your phone number',
                    style: TextStyle(color: Color(0xFF3B2F9F), fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 1:
        return _buildPhoneStep();
      case 2:
        return _buildOtpStep();
      case 3:
        return _buildNewPasswordStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // === ШАГ 1: Ввод телефона ===
  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type your phone number',
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '(+84)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B2F9F))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
        const Text('We texted you a code to verify your phone number',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _canSend && !_loading ? _onSend : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canSend
                  ? const Color(0xFF3B2F9F)
                  : const Color(0xFF3B2F9F).withOpacity(0.2),
              foregroundColor: _canSend ? Colors.white : Colors.white70,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Send',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // === ШАГ 2: Ввод OTP ===
  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type a code',
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Code',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3B2F9F))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _onResend,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B2F9F),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Resend',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            children: [
              const TextSpan(text: 'We texted you a code to verify your phone number '),
              TextSpan(
                text: _phone,
                style: const TextStyle(color: Color(0xFF3B2F9F), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'This code will expired 10 minutes after this message. If you don\'t get a message.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _codeController.text.trim().length >= 4 && !_loading
                ? () => setState(() => _step = 3)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _codeController.text.trim().length >= 4
                  ? const Color(0xFF3B2F9F)
                  : const Color(0xFF3B2F9F).withOpacity(0.2),
              foregroundColor: _codeController.text.trim().length >= 4 ? Colors.white : Colors.white70,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Change password',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // === ШАГ 3: Новый пароль ===
  Widget _buildNewPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New password',
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscureNew,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'New password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B2F9F))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Confirm password',
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Confirm new password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B2F9F))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        if (_confirmPasswordController.text.isNotEmpty &&
            _newPasswordController.text != _confirmPasswordController.text)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Пароли не совпадают',
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _canChange && !_loading ? _onChangePassword : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canChange
                  ? const Color(0xFF3B2F9F)
                  : const Color(0xFF3B2F9F).withOpacity(0.2),
              foregroundColor: _canChange ? Colors.white : Colors.white70,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Change password',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}