import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import '../../models/card.dart';
import '../../services/transfer_service.dart';

class ConfirmScreen extends StatefulWidget {
  final Card fromCard;
  final String recipientName;
  final String cardNumber;
  final String? beneficiaryBank; // новое поле
  final double amount;
  final String content;
  final bool saveBeneficiary;

  const ConfirmScreen({
    super.key,
    required this.fromCard,
    required this.recipientName,
    required this.cardNumber,
    this.beneficiaryBank,
    required this.amount,
    required this.content,
    required this.saveBeneficiary,
  });

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  final _transferService = TransferService();
  final _localAuth = LocalAuthentication();

  bool _biometricVerified = false;
  bool _authenticating = false;
  bool _loading = false;
  bool _showSuccess = false;

  // Тип биометрии: 'touch' или 'face'
  String _biometricType = 'touch';
  // ignore: unused_field
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  /// Проверяет доступность биометрии и её тип
  Future<void> _checkBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        setState(() => _biometricAvailable = false);
        return;
      }

      final available = await _localAuth.getAvailableBiometrics();
      final hasFace = available.contains(BiometricType.face);
      final hasFingerprint = available.contains(BiometricType.fingerprint);

      setState(() {
        _biometricAvailable = true;
        _biometricType = hasFace ? 'face' : (hasFingerprint ? 'touch' : 'touch');
      });
    } catch (e) {
      setState(() => _biometricAvailable = false);
    }
  }

  /// Вызов системного окна биометрии (Touch ID / Face ID)
  Future<void> _authenticateWithBiometric() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Access to the application',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Touch ID for CoBank',
            cancelButton: 'Cancel',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true, // только биометрия, без PIN
        ),
      );

      if (mounted) {
        setState(() {
          _biometricVerified = authenticated;
          _authenticating = false;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() => _authenticating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка биометрии: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _authenticating = false);
    }
  }

  double get _transactionFee => widget.amount * 0.01;

  Future<void> _handleConfirm() async {
    if (!_biometricVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала подтвердите личность'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await _transferService.transfer(
      fromCardId: widget.fromCard.id,
      toAccount: widget.cardNumber,
      amount: widget.amount,
      recipientName: widget.recipientName,
      description: widget.content,
      saveBeneficiary: widget.saveBeneficiary,
    );

    setState(() => _loading = false);

    if (result['success'] == true) {
      setState(() => _showSuccess = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Ошибка перевода'), backgroundColor: Colors.red),
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
            _buildField('To', widget.recipientName),
            const SizedBox(height: 16),

            // Опциональное поле Beneficiary bank (если передано)
            if (widget.beneficiaryBank != null && widget.beneficiaryBank!.isNotEmpty) ...[
              _buildField('Beneficiary bank', widget.beneficiaryBank!),
              const SizedBox(height: 16),
            ],

            _buildField('Card number', widget.cardNumber),
            const SizedBox(height: 16),
            _buildField('Transaction fee', '\$${_transactionFee.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            _buildField('Content', widget.content.isEmpty ? '—' : widget.content),
            const SizedBox(height: 16),
            _buildField('Amount', '\$${widget.amount.toStringAsFixed(0)}'),
            const SizedBox(height: 32),

            // Биометрическая верификация
            const Text(
              'Get OTP to verify transaction',
              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _authenticating ? null : _authenticateWithBiometric,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _biometricVerified
                        ? const Color(0xFF3B2F9F).withOpacity(0.15)
                        : Colors.grey[100],
                    border: Border.all(
                      color: _biometricVerified
                          ? const Color(0xFF3B2F9F)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: _buildBiometricIcon(),
                ),
              ),
            ),

            if (_biometricVerified) ...[
              const SizedBox(height: 8),
              const Center(
                child: Text('Verified',
                    style: TextStyle(color: Color(0xFF3B2F9F), fontWeight: FontWeight.w600)),
              ),
            ],

            const SizedBox(height: 32),

            // Кнопка Confirm
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_biometricVerified && !_loading) ? _handleConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _biometricVerified
                      ? const Color(0xFF3B2F9F)
                      : const Color(0xFF3B2F9F).withOpacity(0.2),
                  foregroundColor: _biometricVerified ? Colors.white : Colors.white70,
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

  /// Иконка биометрии: отпечаток или лицо
  Widget _buildBiometricIcon() {
    final color = _biometricVerified ? const Color(0xFF3B2F9F) : const Color(0xFF3B2F9F).withOpacity(0.5);
    final size = 56.0;

    if (_biometricType == 'face') {
      return Icon(Icons.face_retouching_natural, color: color, size: size);
    }
    return Icon(Icons.fingerprint, color: color, size: size);
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
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B2F9F).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(left: 40, top: 40, child: Icon(Icons.credit_card, size: 80, color: Colors.blue.shade100)),
                    Positioned(right: 30, bottom: 60, child: Icon(Icons.shield, size: 60, color: Colors.green.shade100)),
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
                    Positioned(right: 60, top: 80, child: Icon(Icons.add_circle, size: 50, color: Colors.white)),
                    Positioned(left: 40, bottom: 40, child: Icon(Icons.account_balance_wallet, size: 50, color: Colors.orange)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text('Transaction successfully!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3B2F9F)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text('You have successfully transferred money!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center),
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
}