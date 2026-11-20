import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/beneficiary.dart';
import '../../services/beneficiary_service.dart';

class BeneficiaryListScreen extends StatefulWidget {
  const BeneficiaryListScreen({super.key});

  @override
  State<BeneficiaryListScreen> createState() => _BeneficiaryListScreenState();
}

class _BeneficiaryListScreenState extends State<BeneficiaryListScreen> {
  final _service = BeneficiaryService();
  List<Beneficiary> _beneficiaries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBeneficiaries();
  }

  Future<void> _loadBeneficiaries() async {
    setState(() => _loading = true);
    try {
      final list = await _service.getBeneficiaries();
      if (mounted) {
        setState(() {
          _beneficiaries = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Beneficiary> _getByType(String type) {
    return _beneficiaries.where((b) => b.transferType == type).toList();
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
        title: const Text('Beneficiary',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // Поиск бенефициара
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadBeneficiaries,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('Transfer via card number', _getByType('card_number')),
            const SizedBox(height: 24),
            _buildSection('Transfer to the same bank', _getByType('same_bank')),
            const SizedBox(height: 24),
            _buildSection('Transfer to another bank', _getByType('another_bank')),
            const SizedBox(height: 100), // Отступ для FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/beneficiary/add'),
        backgroundColor: const Color(0xFF3B2F9F),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSection(String title, List<Beneficiary> beneficiaries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Column(
            children: beneficiaries.map((b) => _buildBeneficiaryTile(b)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBeneficiaryTile(Beneficiary b) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[300],
        backgroundImage: b.avatarUrl != null ? NetworkImage(b.avatarUrl!) : null,
        child: b.avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
      ),
      title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: Text(b.cardNumber, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      onTap: () {
        // Переход на экран перевода этому бенефициару
      },
    );
  }
}