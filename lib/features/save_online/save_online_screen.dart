import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SaveOnlineScreen extends StatelessWidget {
  const SaveOnlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text('Save online',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTile(
              context,
              title: 'Add',
              subtitle: 'Add new save online account',
              color: const Color(0xFF3B2F9F),
              onTap: () => context.push('/home/save-online/add'),
            ),
            const SizedBox(height: 16),
            _buildTile(
              context,
              title: 'Management',
              subtitle: 'Manage your save online account',
              color: const Color(0xFF7C3AED),
              onTap: () => context.push('/home/management'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
            Container(
              width: 90,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                title == 'Add' ? Icons.add_circle_outline : Icons.settings,
                color: color,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}