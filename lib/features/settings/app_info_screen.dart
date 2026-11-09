import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  String _version = '9.0.2';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = packageInfo.version.isNotEmpty ? packageInfo.version : '9.0.2';
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      print('Error loading app info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'App information',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),

          // Логотип приложения
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF3B2F9F),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'CaBank E-mobile Banking',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 32),

          // Информация о приложении
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    label: 'Date of manufacture',
                    value: 'Dec 2019',
                  ),
                  const Divider(height: 1),
                  _buildInfoRow(
                    label: 'Version',
                    value: _version,
                  ),
                  const Divider(height: 1),
                  _buildInfoRow(
                    label: 'Language',
                    value: 'English',
                    onTap: () {
                      // Изменение языка
                    },
                  ),
                  if (_buildNumber.isNotEmpty) ...[
                    const Divider(height: 1),
                    _buildInfoRow(
                      label: 'Build number',
                      value: _buildNumber,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF3B2F9F),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}