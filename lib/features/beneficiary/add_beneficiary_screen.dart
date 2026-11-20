import 'package:flutter/material.dart';
import '../../services/beneficiary_service.dart';

class AddBeneficiaryScreen extends StatefulWidget {
  const AddBeneficiaryScreen({super.key});

  @override
  State<AddBeneficiaryScreen> createState() => _AddBeneficiaryScreenState();
}

class _AddBeneficiaryScreenState extends State<AddBeneficiaryScreen> {
  final _service = BeneficiaryService();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _bankController = TextEditingController();
  final _branchController = TextEditingController();

  String _transferType = 'another_bank';
  bool _saving = false;
  bool _showForm = false;

  static const List<Map<String, dynamic>> _transferTypes = [
    {'id': 'card_number', 'label': 'Transfer via\ncard number', 'icon': Icons.credit_card, 'color': Colors.grey},
    {'id': 'same_bank', 'label': 'Transfer to\nthe same bank', 'icon': Icons.person, 'color': Colors.grey},
    {'id': 'another_bank', 'label': 'Transfer to\nanother bank', 'icon': Icons.account_balance, 'color': Colors.orange},
  ];

  bool get _canSave {
    return _nameController.text.trim().isNotEmpty &&
        _cardNumberController.text.trim().isNotEmpty &&
        (_transferType == 'card_number' ||
            (_bankController.text.trim().isNotEmpty && _branchController.text.trim().isNotEmpty));
  }

  Future<void> _handleSave() async {
    if (!_canSave) return;

    setState(() => _saving = true);

    final result = await _service.addBeneficiary(
      name: _nameController.text.trim(),
      cardNumber: _cardNumberController.text.trim(),
      transferType: _transferType,
      bankName: _bankController.text.trim().isEmpty ? null : _bankController.text.trim(),
      branchName: _branchController.text.trim().isEmpty ? null : _branchController.text.trim(),
    );

    setState(() => _saving = false);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Бенефициар добавлен'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Ошибка'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add new',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Аватар пользователя
            _buildAvatar(),
            const SizedBox(height: 24),

            // Выбор типа перевода
            _buildTransferTypeSelector(),
            const SizedBox(height: 24),

            // Форма
            if (_showForm) _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, size: 60, color: Colors.grey),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B2F9F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Push Puttichai',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B2F9F))),
      ],
    );
  }

  Widget _buildTransferTypeSelector() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _transferTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final type = _transferTypes[index];
          final isSelected = _transferType == type['id'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _transferType = type['id'] as String;
                _showForm = true;
              });
            },
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? type['color'] as Color : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(type['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.grey[600], size: 32),
                  const SizedBox(height: 8),
                  Text(type['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600], fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // Choose bank (только для another_bank)
          if (_transferType == 'another_bank') ...[
            const Text('Choose bank',
                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _bankController,
              decoration: InputDecoration(
                hintText: 'Citibank',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Choose branch (только для another_bank)
          if (_transferType == 'another_bank') ...[
            const Text('Choose branch',
                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _branchController,
              decoration: InputDecoration(
                hintText: 'New York',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Transaction name
          const Text('Transaction name',
              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Push Putchai',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Card number
          const Text('Card number',
              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '1235 6478 990',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 24),

          // Кнопка сохранения
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _canSave && !_saving ? _handleSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSave ? const Color(0xFF3B2F9F) : const Color(0xFF3B2F9F).withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save to directory',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _bankController.dispose();
    _branchController.dispose();
    super.dispose();
  }
}