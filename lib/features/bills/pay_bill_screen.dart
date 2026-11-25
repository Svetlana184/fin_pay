import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/bill_provider.dart';
import '../../services/bill_service.dart';

class PayBillScreen extends StatefulWidget {
  final String billType; // 'electric' | 'water' | 'mobile' | 'internet'
  const PayBillScreen({super.key, required this.billType});

  @override
  State<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends State<PayBillScreen> {
  final _billService = BillService();
  final _codeController = TextEditingController();

  List<BillProvider> _providers = [];
  BillProvider? _selectedProvider;
  bool _checking = false;
  bool _loadingProviders = true;

  String get _title {
    switch (widget.billType) {
      case 'electric':  return 'Electric bill';
      case 'water':     return 'Water bill';
      case 'mobile':    return 'Mobile bill';
      case 'internet':  return 'Internet bill';
      default:          return 'Pay the bill';
    }
  }

  String get _companyLabel {
    switch (widget.billType) {
      case 'electric':  return 'Choose electric company';
      case 'water':     return 'Choose water company';
      case 'mobile':    return 'Choose mobile operator';
      case 'internet':  return 'Choose internet provider';
      default:          return 'Choose company';
    }
  }

  String get _codeLabel {
    switch (widget.billType) {
      case 'electric':  return 'Type electric bill code';
      case 'water':     return 'Type water bill code';
      case 'mobile':    return 'Type mobile bill code';
      case 'internet':  return 'Type internet bill code';
      default:          return 'Type bill code';
    }
  }

  bool get _canCheck =>
      _selectedProvider != null && _codeController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() => _loadingProviders = true);
    try {
      final list = await _billService.getProviders(widget.billType);
      if (mounted) {
        setState(() {
          _providers = list;
          _loadingProviders = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProviders = false);
    }
  }

  Future<void> _onCheck() async {
    if (!_canCheck) return;
    setState(() => _checking = true);
    try {
      final result = await _billService.findBillByCode(
        code: _codeController.text.trim(),
        providerId: _selectedProvider!.id,
      );
      if (mounted) {
        setState(() => _checking = false);
        context.push('/home/pay-bill/${widget.billType}/details', extra: {
          ...result,
          'provider': _selectedProvider!.toJson(),
          'bill_type': widget.billType,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _checking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
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
      body: _loadingProviders
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown компании
              Text(_companyLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<BillProvider>(
                    isExpanded: true,
                    value: _selectedProvider,
                    hint: const Text('Choose company',
                        style: TextStyle(color: Colors.grey)),
                    items: _providers.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.name),
                    )).toList(),
                    onChanged: (p) => setState(() => _selectedProvider = p),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Поле кода
              Text(_codeLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Bill code',
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
              const Text('Please enter the correct bill code to check information.',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),

              // Кнопка Check
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _canCheck && !_checking ? _onCheck : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canCheck
                        ? const Color(0xFF3B2F9F)
                        : const Color(0xFF3B2F9F).withOpacity(0.2),
                    foregroundColor: _canCheck ? Colors.white : Colors.white70,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _checking
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Check',
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
    _codeController.dispose();
    super.dispose();
  }
}