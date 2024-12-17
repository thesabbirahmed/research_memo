import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _generalNotifications = true;
  bool _revisionReminders = true;
  ThemeMode _themeMode = ThemeMode.system;
  String _appVersion = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
  }

  /// Load Settings
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _generalNotifications = prefs.getBool('generalNotifications') ?? true;
      _revisionReminders = prefs.getBool('revisionReminders') ?? true;
      _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index];
    });
  }

  /// Save Settings
  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('generalNotifications', _generalNotifications);
    prefs.setBool('revisionReminders', _revisionReminders);
    prefs.setInt('themeMode', _themeMode.index);
  }

  /// Load App Version
  Future<void> _loadAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  /// Change Theme
  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
      widget.onThemeChanged(mode);
      _saveSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildSectionTitle('Preferences'),
            _buildSettingsCard(
              [
                _buildSwitchTile(
                  title: 'General Notifications',
                  value: _generalNotifications,
                  onChanged: (value) {
                    setState(() {
                      _generalNotifications = value;
                      _saveSettings();
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Revision Reminders',
                  value: _revisionReminders,
                  onChanged: (value) {
                    setState(() {
                      _revisionReminders = value;
                      _saveSettings();
                    });
                  },
                ),
              ],
            ),
            _buildSectionTitle('Appearance'),
            _buildSettingsCard(
              [
                _buildThemeSelection(),
              ],
            ),
            _buildSectionTitle('About'),
            _buildSettingsCard(
              [
                ListTile(
                  leading: Icon(Icons.info, color: Colors.blueAccent),
                  title: Text('App Version'),
                  subtitle: Text('Version $_appVersion'),
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.redAccent),
                  title: Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  /// Settings Card
  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  /// Switch Tile
  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  /// Theme Selection Dropdown
  Widget _buildThemeSelection() {
    return ListTile(
      leading: Icon(Icons.palette, color: Colors.blueAccent),
      title: Text('Theme Selection'),
      trailing: DropdownButton<ThemeMode>(
        value: _themeMode,
        onChanged: (ThemeMode? newValue) {
          if (newValue != null) _changeTheme(newValue);
        },
        items: [
          DropdownMenuItem(value: ThemeMode.system, child: Text('System Default')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('Light Theme')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark Theme')),
        ],
      ),
    );
  }
}
