import 'package:flutter/material.dart';

class InterestRateScreen extends StatelessWidget {
  const InterestRateScreen({super.key});

  // Демо-данные (в prod — эндпоинт GET /api/interest-rates)
  static const _rows = [
    ['Individual customers', '1m', '4.50%'],
    ['Corporate customers', '2m', '5.50%'],
    ['Individual customers', '1m', '4.50%'],
    ['Corporate customers', '6m', '2.50%'],
    ['Individual customers', '1m', '4.50%'],
    ['Corporate customers', '8m', '6.50%'],
    ['Individual customers', '1m', '4.50%'],
    ['Individual customers', '1m', '4.50%'],
    ['Corporate customers', '7m', '6.80%'],
    ['Individual customers', '1m', '4.50%'],
    ['Individual customers', '12m', '5.90%'],
    ['Individual customers', '1m', '4.50%'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50], elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('Interest rate', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                const Expanded(child: Text('Interest kind', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                const SizedBox(width: 60, child: Text('Deposit', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                const SizedBox(width: 70, child: Text('Rate', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _rows.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, i) {
                final r = _rows[i];
                return ListTile(
                  title: Text(r[0], style: const TextStyle(color: Colors.black87)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 40, child: Text(r[1], textAlign: TextAlign.right)),
                      const SizedBox(width: 20),
                      SizedBox(width: 60, child: Text(r[2], textAlign: TextAlign.right,
                          style: const TextStyle(color: Color(0xFF3B2F9F), fontWeight: FontWeight.bold))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}