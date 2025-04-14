import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medi_flow_new/auth_service.dart';
import 'package:medi_flow_new/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  String? _userName;
  String? _userEmail;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  late SharedPreferences _prefs;

  Color get _backgroundColor =>
      _darkModeEnabled ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
  Color get _cardColor =>
      _darkModeEnabled ? const Color(0xFF1E1E1E) : Colors.white;
  Color get _textColor => _darkModeEnabled ? Colors.white : Colors.black87;
  Color get _subtitleColor =>
      _darkModeEnabled ? Colors.white70 : Colors.black54;
  Color get _dividerColor =>
      _darkModeEnabled ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadPreferences();
  }

  Future<void> _loadUserInfo() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = _prefs.getString('user_name') ?? 'User';
      _userEmail = _prefs.getString('user_email') ?? '';
    });
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _darkModeEnabled = _prefs.getBool('settingsDarkMode') ?? false;
      _notificationsEnabled = _prefs.getBool('notifications') ?? true;
      _selectedLanguage = _prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _darkModeEnabled = value);
    await _prefs.setBool('settingsDarkMode', value);
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await _prefs.setBool('notifications', value);
  }

  Future<void> _setLanguage(String language) async {
    setState(() => _selectedLanguage = language);
    await _prefs.setString('language', language);
  }

  void _showPersonalInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text(
          'Personal Information',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', _userName ?? 'Not set'),
            const SizedBox(height: 12),
            _buildInfoRow('Email', _userEmail ?? 'Not set'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: const Color(0xFF2D9CDB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: _subtitleColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        backgroundColor: _cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionCard(
              title: 'Account',
              children: [
                _buildSettingsItem(
                  title: 'Personal Information',
                  subtitle: 'View your profile details',
                  trailing: Icon(
                    Icons.person_outline,
                    color: const Color(0xFF2D9CDB),
                  ),
                  onTap: _showPersonalInfoDialog,
                ),
                Divider(color: _dividerColor),
                _buildSettingsItem(
                  title: 'Security',
                  subtitle: 'Password and security settings',
                  trailing: Icon(
                    Icons.security_outlined,
                    color: const Color(0xFF2D9CDB),
                  ),
                  onTap: () {
                    // Navigate to security settings
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Preferences Section
            _buildSectionCard(
              title: 'Preferences',
              children: [
                _buildSettingsItem(
                  title: 'Dark Mode',
                  subtitle: 'Enable dark theme for settings',
                  trailing: Switch(
                    value: _darkModeEnabled,
                    onChanged: _toggleDarkMode,
                    activeColor: const Color(0xFF2D9CDB),
                  ),
                ),
                Divider(color: _dividerColor),
                _buildSettingsItem(
                  title: 'Notifications',
                  subtitle: 'Receive app notifications',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    activeColor: const Color(0xFF2D9CDB),
                  ),
                ),
                Divider(color: _dividerColor),
                _buildSettingsItem(
                  title: 'Language',
                  subtitle: 'App language',
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    dropdownColor: _cardColor,
                    style: GoogleFonts.poppins(
                      color: _textColor,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'English',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'Spanish',
                        child: Text('Spanish'),
                      ),
                      DropdownMenuItem(
                        value: 'French',
                        child: Text('French'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) _setLanguage(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Support Section
            _buildSectionCard(
              title: 'Support',
              children: [
                _buildSettingsItem(
                  title: 'Help Center',
                  subtitle: 'Get help with using the app',
                  trailing: Icon(
                    Icons.help_outline,
                    color: const Color(0xFF2D9CDB),
                  ),
                  onTap: () {
                    // Navigate to help center
                  },
                ),
                Divider(color: _dividerColor),
                _buildSettingsItem(
                  title: 'Send Feedback',
                  subtitle: 'Help us improve the app',
                  trailing: Icon(
                    Icons.feedback_outlined,
                    color: const Color(0xFF2D9CDB),
                  ),
                  onTap: () {
                    // Navigate to feedback form
                  },
                ),
                Divider(color: _dividerColor),
                _buildSettingsItem(
                  title: 'About',
                  subtitle: 'App version and information',
                  trailing: Icon(
                    Icons.info_outline,
                    color: const Color(0xFF2D9CDB),
                  ),
                  onTap: () {
                    // Show about dialog
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _signOut,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.red),
                  backgroundColor: _cardColor,
                ),
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: _cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _subtitleColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
}
