import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = true;
  double _searchRadius = 10.0;
  String _selectedLanguage = 'English';
  String _selectedUnit = 'Kilometers';

  final List<String> _languages = ['English', 'Spanish', 'French', 'Arabic', 'Hindi'];
  final List<String> _units = ['Kilometers', 'Miles'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              _buildDivider(),
              _buildSettingsSection(
                'General',
                [
                  _buildLanguageSetting(),
                  _buildUnitSetting(),
                  _buildThemeSetting(),
                ],
              ),
              _buildDivider(),
              _buildSettingsSection(
                'Notifications',
                [
                  _buildSwitchTile(
                    'Push Notifications',
                    'Receive notifications about requests and updates',
                    _notificationsEnabled,
                    Icons.notifications,
                    (value) => setState(() => _notificationsEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Email Notifications',
                    'Receive updates via email',
                    _emailNotifications,
                    Icons.email,
                    (value) => setState(() => _emailNotifications = value),
                  ),
                  _buildSwitchTile(
                    'SMS Notifications',
                    'Receive updates via SMS',
                    _smsNotifications,
                    Icons.sms,
                    (value) => setState(() => _smsNotifications = value),
                  ),
                ],
              ),
              _buildDivider(),
              _buildSettingsSection(
                'Location & Privacy',
                [
                  _buildSwitchTile(
                    'Location Services',
                    'Allow app to access your location',
                    _locationEnabled,
                    Icons.location_on,
                    (value) => setState(() => _locationEnabled = value),
                  ),
                  _buildSearchRadiusSetting(),
                ],
              ),
              _buildDivider(),
              _buildSettingsSection(
                'Account',
                [
                  _buildActionTile(
                    'Personal Information',
                    'Update your profile details',
                    Icons.person,
                    () => _showComingSoonSnackBar('Personal Information'),
                  ),
                  _buildActionTile(
                    'Medical History',
                    'View and update your medical records',
                    Icons.medical_information,
                    () => _showComingSoonSnackBar('Medical History'),
                  ),
                  _buildActionTile(
                    'Emergency Contacts',
                    'Manage your emergency contacts',
                    Icons.emergency,
                    () => _showComingSoonSnackBar('Emergency Contacts'),
                  ),
                ],
              ),
              _buildDivider(),
              _buildSettingsSection(
                'Support',
                [
                  _buildActionTile(
                    'Help Center',
                    'FAQs and support resources',
                    Icons.help,
                    () => _showComingSoonSnackBar('Help Center'),
                  ),
                  _buildActionTile(
                    'Contact Us',
                    'Get in touch with our support team',
                    Icons.support_agent,
                    () => _showComingSoonSnackBar('Contact Us'),
                  ),
                  _buildActionTile(
                    'Privacy Policy',
                    'Read our privacy policy',
                    Icons.privacy_tip,
                    () => _showComingSoonSnackBar('Privacy Policy'),
                  ),
                  _buildActionTile(
                    'Terms of Service',
                    'Read our terms of service',
                    Icons.description,
                    () => _showComingSoonSnackBar('Terms of Service'),
                  ),
                ],
              ),
              _buildDivider(),
              _buildSettingsSection(
                'Data & Storage',
                [
                  _buildActionTile(
                    'Clear Cache',
                    'Free up storage space',
                    Icons.cleaning_services,
                    _showClearCacheDialog,
                  ),
                  _buildActionTile(
                    'Download My Data',
                    'Get a copy of your data',
                    Icons.download,
                    () => _showComingSoonSnackBar('Download My Data'),
                  ),
                ],
              ),
              _buildDivider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    OutlinedButton(
                      onPressed: _showDeleteAccountDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_forever),
                          SizedBox(width: 8),
                          Text('Delete Account'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _showLogoutDialog,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Color(0xFFCC2B2B)),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(color: Color(0xFFCC2B2B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // App version
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(
                color: const Color(0xFFCC2B2B),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 40,
                color: Color(0xFFCC2B2B),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'john.doe@example.com',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _showComingSoonSnackBar('Edit Profile'),
                  icon: const Icon(
                    Icons.edit,
                    size: 16,
                  ),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFCC2B2B),
                    side: const BorderSide(color: Color(0xFFCC2B2B)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[200],
      thickness: 8,
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCC2B2B),
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: const Color(0xFFCC2B2B)),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFCC2B2B)),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLanguageSetting() {
    return ListTile(
      leading: const Icon(Icons.language, color: Color(0xFFCC2B2B)),
      title: const Text('Language'),
      subtitle: Text(
        _selectedLanguage,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        underline: const SizedBox(),
        items: _languages.map((String language) {
          return DropdownMenuItem<String>(
            value: language,
            child: Text(language),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() => _selectedLanguage = value);
          }
        },
      ),
    );
  }

  Widget _buildUnitSetting() {
    return ListTile(
      leading: const Icon(Icons.straighten, color: Color(0xFFCC2B2B)),
      title: const Text('Distance Unit'),
      subtitle: Text(
        _selectedUnit,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: DropdownButton<String>(
        value: _selectedUnit,
        underline: const SizedBox(),
        items: _units.map((String unit) {
          return DropdownMenuItem<String>(
            value: unit,
            child: Text(unit),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() => _selectedUnit = value);
          }
        },
      ),
    );
  }

  Widget _buildThemeSetting() {
    return SwitchListTile(
      secondary: const Icon(Icons.dark_mode, color: Color(0xFFCC2B2B)),
      title: const Text('Dark Mode'),
      subtitle: Text(
        'Switch between light and dark theme',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      value: _isDarkMode,
      onChanged: (bool value) {
        setState(() => _isDarkMode = value);
      },
    );
  }

  Widget _buildSearchRadiusSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.radar, color: Color(0xFFCC2B2B)),
          title: const Text('Search Radius'),
          subtitle: Text(
            '${_searchRadius.toStringAsFixed(1)} ${_selectedUnit == 'Kilometers' ? 'km' : 'mi'}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFCC2B2B),
              inactiveTrackColor: const Color(0xFFCC2B2B).withOpacity(0.2),
              thumbColor: const Color(0xFFCC2B2B),
              overlayColor: const Color(0xFFCC2B2B).withOpacity(0.1),
              valueIndicatorColor: const Color(0xFFCC2B2B),
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: Slider(
              value: _searchRadius,
              min: 1,
              max: 50,
              divisions: 49,
              label: '${_searchRadius.toStringAsFixed(1)} ${_selectedUnit == 'Kilometers' ? 'km' : 'mi'}',
              onChanged: (value) {
                setState(() => _searchRadius = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature feature coming soon!')),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the app cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonSnackBar('Clear Cache');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC2B2B),
            ),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonSnackBar('Delete Account');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonSnackBar('Logout');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC2B2B),
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
} 