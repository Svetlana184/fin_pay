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
  String _language = 'en';
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
          _user = userData as User?;
          _biometricEnabled = bioEnabled;
          _language = lang;
          _loading = false;
        });
      }
    } catch (e) {
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
          : Stack(
        children: [
          // Синяя шапка
          Container(
            height: 220,
            decoration: const BoxDecoration(
              color: Color(0xFF3B2F9F),
            ),
          ),
          // Белая карточка с закруглённым верхом
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.only(top: 60, bottom: 20),
                children: [
                  // Аватар + имя (выступают над белой карточкой)
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildMenuItem('Password', onTap: () => context.push('/change-password')),
                  _buildMenuItem('Touch ID',
                      trailing: Switch(
                        value: _biometricEnabled,
                        activeColor: const Color(0xFF3B2F9F),
                        onChanged: (v) async {
                          if (v) {
                            final ok = await _settingsService.authenticateWithBiometrics();
                            if (ok) {
                              await _settingsService.setBiometricEnabled(true);
                              setState(() => _biometricEnabled = true);
                            }
                          } else {
                            await _settingsService.setBiometricEnabled(false);
                            setState(() => _biometricEnabled = false);
                          }
                        },
                      )),
                  _buildMenuItem('Languages',
                      trailing: Text(_language.toUpperCase(),
                          style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                      onTap: _showLanguagePicker),
                  _buildMenuItem('App information',
                      onTap: () => context.push('/app-info')),
                  _buildMenuItem('Customer care',
                      trailing: Text('19008989',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage: _user?.avatarUrl != null ? NetworkImage(_user!.avatarUrl!) : null,
          child: _user?.avatarUrl == null
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          _user?.fullName ?? 'Push Puttichai',
          style: const TextStyle(
            color: Color(0xFF3B2F9F),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String title, {Widget? trailing, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
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
            onChanged: (v) => Navigator.pop(ctx, v),
          )).toList(),
        ),
      ),
    );
    if (selected != null) {
      await _settingsService.setLanguage(selected);
      setState(() => _language = selected);
    }
  }
}