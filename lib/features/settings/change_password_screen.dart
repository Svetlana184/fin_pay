import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

enum PasswordMode { change, reset }

class ChangePasswordScreen extends StatefulWidget {
  final PasswordMode mode;
  final String? phone; // только для mode == reset

  const ChangePasswordScreen({
    super.key,
    this.mode = PasswordMode.change,
    this.phone,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _authService = AuthService();

  final _recentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureRecent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  // Заголовок и лейблы зависят от режима
  String get _title => 'Change password';

  String get _recentLabel =>
      widget.mode == PasswordMode.change ? 'Recent password' : 'Type your new password';

  String get _recentHint =>
      widget.mode == PasswordMode.change ? 'Recent password' : '';

  bool get _showRecentField => widget.mode == PasswordMode.change;

  bool get _canSubmit {
    if (_newController.text.isEmpty || _confirmController.text.isEmpty) return false;
    if (_newController.text != _confirmController.text) return false;
    if (_newController.text.length < 6) return false;
    if (widget.mode == PasswordMode.change && _recentController.text.isEmpty) return false;
    return true;
  }

  Future<void> _onSubmit() async {
    if (!_canSubmit) return;
    setState(() => _loading = true);

    Map<String, dynamic> result;
    if (widget.mode == PasswordMode.change) {
      result = await _authService.changePassword(
        recentPassword: _recentController.text,
        newPassword: _newController.text,
        confirmPassword: _confirmController.text,
      );
    } else {
      result = await _authService.resetPassword(
        phone: widget.phone ?? '',
        otp: '', // OTP уже проверен на предыдущем шаге
        newPassword: _newController.text,
      );
    }

    setState(() => _loading = false);

    if (!mounted) return;
    if (result['success'] == true) {
      context.go('/password-changed');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Ошибка'), backgroundColor: Colors.red),
      );
    }
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
        title: Text(_title,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent password (только для режима change)
              if (_showRecentField) ...[
                const Text('Recent password',
                    style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _buildPasswordField(_recentController, 'Recent password', _obscureRecent, () {
                  setState(() => _obscureRecent = !_obscureRecent);
                }),
                const SizedBox(height: 20),
              ],

              // New password
              Text(
                widget.mode == PasswordMode.reset ? 'Type your new password' : 'New password',
                style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(_newController, 'New password', _obscureNew, () {
                setState(() => _obscureNew = !_obscureNew);
              }),
              const SizedBox(height: 20),

              // Confirm password
              const Text('Confirm password',
                  style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildPasswordField(_confirmController, 'Confirm new password', _obscureConfirm, () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              }),

              // Ошибка несовпадения
              if (_confirmController.text.isNotEmpty &&
                  _newController.text != _confirmController.text)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Пароли не совпадают',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ),

              const SizedBox(height: 28),

              // Кнопка
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canSubmit && !_loading ? _onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSubmit
                        ? const Color(0xFF3B2F9F)
                        : const Color(0xFF3B2F9F).withOpacity(0.2),
                    foregroundColor: _canSubmit ? Colors.white : Colors.white70,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Change password',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller,
      String hint,
      bool obscure,
      VoidCallback onToggle,
      ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B2F9F))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: onToggle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}