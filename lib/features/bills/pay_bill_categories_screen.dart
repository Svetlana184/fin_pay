import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PayBillCategoriesScreen extends StatelessWidget {
  const PayBillCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'type': 'electric',
        'title': 'Electric bill',
        'subtitle': 'Pay electric bill this month',
        'color': const Color(0xFFFF9800),
        'icon': Icons.electrical_services,
      },
      {
        'type': 'water',
        'title': 'Water bill',
        'subtitle': 'Pay water bill this month',
        'color': const Color(0xFF2196F3),
        'icon': Icons.water_drop,
      },
      {
        'type': 'mobile',
        'title': 'Mobile bill',
        'subtitle': 'Pay mobile bill this month',
        'color': const Color(0xFFE91E63),
        'icon': Icons.phone_android,
      },
      {
        'type': 'internet',
        'title': 'Internet bill',
        'subtitle': 'Pay internet bill this month',
        'color': const Color(0xFF9C27B0),
        'icon': Icons.wifi,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pay the bill',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          return GestureDetector(
            onTap: () => context.push('/home/pay-bill/${cat['type']}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat['title'] as String,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(cat['subtitle'] as String,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: (cat['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(cat['icon'] as IconData,
                        color: cat['color'] as Color, size: 40),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}