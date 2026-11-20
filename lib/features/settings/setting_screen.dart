import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';
import '../../services/settings_service.dart';
import '../../models/user.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _userService = UserService();
  final _settingsService = SettingsService();
  User? _user;
  bool _biometricEnabled = false;
  String _language = 'ru';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final userData = await _userService.getProfile();
      final bioEnabled = await _settingsService.isBiometricEnabled();
      final lang = await _settingsService.getLanguage();
      if (mounted) {
        setState(() {
          _user = User.fromJson(userData);
          _biometricEnabled = bioEnabled;
          _language = lang;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('SettingScreen load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B2F9F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Setting',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Профиль пользователя
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
            decoration: const BoxDecoration(
              color: Color(0xFF3B2F9F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: _user?.avatarUrl != null
                      ? NetworkImage(_user!.avatarUrl!)
                      : null,
                  child: _user?.avatarUrl == null
                      ? const Icon(Icons.person, size: 50, color: Color(0xFF3B2F9F))
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _user?.fullName ?? 'Пользователь',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Меню настроек
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Password',
                  onTap: () => context.push('/setting/change-password'),
                ),
                _buildMenuItem(
                  icon: Icons.fingerprint,
                  title: 'Touch ID',
                  trailing: Switch(
                    value: _biometricEnabled,
                    activeColor: const Color(0xFF3B2F9F),
                    onChanged: (value) async {
                      if (value) {
                        final authenticated = await _settingsService.authenticateWithBiometrics();
                        if (authenticated) {
                          await _settingsService.setBiometricEnabled(true);
                          setState(() => _biometricEnabled = true);
                        }
                      } else {
                        await _settingsService.setBiometricEnabled(false);
                        setState(() => _biometricEnabled = false);
                      }
                    },
                  ),
                ),
                _buildMenuItem(
                  icon: Icons.language,
                  title: 'Languages',
                  trailing: Text(_language.toUpperCase(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  onTap: () => _showLanguagePicker(),
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'App information',
                  onTap: () => context.push('/setting/app-info'),
                ),
                _buildMenuItem(
                  icon: Icons.headset_mic,
                  title: 'Customer care',
                  trailing: const Text('19008989',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  onTap: () {
                    // Открыть звонок или чат
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Звонок в поддержку: 19008989')),
                    );
                  },
                ),
                const SizedBox(height: 30),
                // Кнопка выхода
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showLogoutDialog(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Logout',
                        style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF3B2F9F), size: 24),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showLanguagePicker() async {
    final languages = {'ru': 'Русский', 'en': 'English', 'es': 'Español'};
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выберите язык'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((e) => RadioListTile(
            title: Text(e.value),
            value: e.key,
            groupValue: _language,
            onChanged: (value) => Navigator.pop(ctx, value),
          )).toList(),
        ),
      ),
    );
    if (selected != null) {
      await _settingsService.setLanguage(selected);
      setState(() => _language = selected);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выход из системы'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _settingsService.logout();
              if (mounted) {
                // ignore: use_build_context_synchronously
                Navigator.pop(ctx);
                // Используем go для перехода на Login
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}