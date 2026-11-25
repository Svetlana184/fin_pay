import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import '../../models/card.dart';
import '../../services/mobile_prepaid_service.dart';
import '../../services/settings_service.dart';

class MobilePrepaidConfirmScreen extends StatefulWidget {
  final Card fromCard;
  final String phone;
  final double amount;

  const MobilePrepaidConfirmScreen({
    super.key,
    required this.fromCard,
    required this.phone,
    required this.amount,
  });

  @override
  State<MobilePrepaidConfirmScreen> createState() => _MobilePrepaidConfirmScreenState();
}

class _MobilePrepaidConfirmScreenState extends State<MobilePrepaidConfirmScreen> {
  final _service = MobilePrepaidService();
  final _settingsService = SettingsService();
  final _localAuth = LocalAuthentication();
  final _otpController = TextEditingController();

  // 'otp' | 'biometric'
  String _verifyMode = 'otp';
  bool _biometricVerified = false;
  bool _otpVerified = false;
  bool _loading = false;
  bool _showSuccess = false;

  bool get _verified => _verifyMode == 'biometric' ? _biometricVerified : _otpVerified;

  @override
  void initState() {
    super.initState();
    _resolveMode();
  }

  /// Если биометрия включена в настройках и доступна — режим Touch ID, иначе OTP
  Future<void> _resolveMode() async {
    try {
      final enabled = await _settingsService.isBiometricEnabled();
      final available = await _localAuth.canCheckBiometrics;
      if (mounted) {
        setState(() => _verifyMode = (enabled && available) ? 'biometric' : 'otp');
      }
    } catch (_) {
      if (mounted) setState(() => _verifyMode = 'otp');
    }
  }

  Future<void> _handleGetOtp() async {
    final otp = await _service.getOtp();
    _otpController.text = otp;
    setState(() => _otpVerified = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP код: $otp'), backgroundColor: Colors.green),
    );
  }

  Future<void> _handleBiometric() async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: 'Access to the application',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Touch ID for CoBank',
            cancelButton: 'Cancel',
          )
        ],
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
      );
      if (mounted) setState(() => _biometricVerified = ok);
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка биометрии: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleConfirm() async {
    if (!_verified) return;
    setState(() => _loading = true);

    final result = await _service.recharge(
      accountId: widget.fromCard.id,
      phone: widget.phone,
      amount: widget.amount,
      otpCode: _verifyMode == 'otp' ? _otpController.text : null,
      biometricVerified: _verifyMode == 'biometric' && _biometricVerified,
    );

    setState(() => _loading = false);

    if (result['success'] == true) {
      setState(() => _showSuccess = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Ошибка'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Confirm',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Confirm transaction information',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),
            _buildField('From', '**** **** ${widget.fromCard.last4Digits}'),
            const SizedBox(height: 16),
            _buildField('To', widget.phone),
            const SizedBox(height: 16),
            _buildField('Amount', '\$${widget.amount.toStringAsFixed(0)}'),
            const SizedBox(height: 32),
            _buildVerificationBlock(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _verified && !_loading ? _handleConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _verified
                      ? const Color(0xFF3B2F9F)
                      : const Color(0xFF3B2F9F).withOpacity(0.2),
                  foregroundColor: _verified ? Colors.white : Colors.white70,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBlock() {
    if (_verifyMode == 'biometric') {
      // Скрины 4-5: Touch ID
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _biometricVerified
                  ? 'Touch ID verified'
                  : 'Use Touch ID to verify transaction',
              style: const TextStyle(
                  color: Color(0xFF3B2F9F), fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _biometricVerified ? null : _handleBiometric,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _biometricVerified
                    ? const Color(0xFF3B2F9F).withOpacity(0.15)
                    : Colors.grey[100],
                border: Border.all(
                  color: _biometricVerified ? const Color(0xFF3B2F9F) : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Icon(Icons.fingerprint,
                  size: 56,
                  color: _biometricVerified ? const Color(0xFF3B2F9F) : const Color(0xFF3B2F9F).withOpacity(0.5)),
            ),
          ),
        ],
      );
    }

    // Скрин 3: OTP
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Get OTP to verify transaction',
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _otpController,
                onChanged: (v) => setState(() => _otpVerified = v.isNotEmpty),
                decoration: InputDecoration(
                  hintText: 'OTP',
                  suffixIcon: const Icon(Icons.chevron_right),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _handleGetOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B2F9F),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Get OTP',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B2F9F).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.check_circle, size: 100, color: Color(0xFF3B2F9F)),
              ),
              const SizedBox(height: 40),
              const Text('Transaction successfully!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3B2F9F)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text('You have successfully topped up the phone.',
                  style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B2F9F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}