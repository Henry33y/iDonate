import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'Arabic',
    'Hindi'
  ];
  final List<String> _units = ['Kilometers', 'Miles'];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

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
                  _buildLanguageSetting(settingsProvider),
                  _buildUnitSetting(settingsProvider),
                  _buildThemeSetting(settingsProvider),
                ],
              ),
              _buildDivider(),
              _buildSettingsSection(
                'Notifications',
                [
                  _buildSwitchTile(
                    'Push Notifications',
                    'Receive notifications about requests and updates',
                    settingsProvider.notificationsEnabled,
                    Icons.notifications,
                    (value) => settingsProvider.setNotificationsEnabled(value),
                  ),
                  _buildSwitchTile(
                    'Email Notifications',
                    'Receive updates via email',
                    settingsProvider.emailNotifications,
                    Icons.email,
                    (value) => settingsProvider.setEmailNotifications(value),
                  ),
                  _buildSwitchTile(
                    'SMS Notifications',
                    'Receive updates via SMS',
                    settingsProvider.smsNotifications,
                    Icons.sms,
                    (value) => settingsProvider.setSmsNotifications(value),
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
                    settingsProvider.locationEnabled,
                    Icons.location_on,
                    (value) => settingsProvider.setLocationEnabled(value),
                  ),
                  _buildSearchRadiusSetting(settingsProvider),
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
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
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
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyPage(),
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    'Terms of Service',
                    'Read our terms of service',
                    Icons.description,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfServicePage(),
                        ),
                      );
                    },
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
                      onPressed: () => _showDeleteAccountDialog(authProvider),
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
                      onPressed: () => _showLogoutDialog(authProvider),
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final displayName = userData['isAnonymous'] == true
            ? userData['anonymizedUsername'] ?? 'Anonymous User'
            : userData['name'] ?? 'Anonymous User';
        final email = user?.email ?? 'Not signed in';

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
                child: Center(
                  child: user?.photoURL != null
                      ? ClipOval(
                          child: Image.network(
                            user!.photoURL!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFFCC2B2B),
                            ),
                          ),
                        )
                      : const Icon(
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
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
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
      },
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

  Widget _buildLanguageSetting(SettingsProvider settingsProvider) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Language'),
      subtitle: Text(settingsProvider.language),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showLanguageDialog(settingsProvider),
    );
  }

  Widget _buildUnitSetting(SettingsProvider settingsProvider) {
    return ListTile(
      leading: const Icon(Icons.straighten),
      title: const Text('Distance Unit'),
      subtitle: Text(settingsProvider.unit),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showUnitDialog(settingsProvider),
    );
  }

  Widget _buildThemeSetting(SettingsProvider settingsProvider) {
    return SwitchListTile(
      secondary: const Icon(Icons.dark_mode),
      title: const Text('Dark Mode'),
      subtitle: const Text('Enable dark theme'),
      value: settingsProvider.isDarkMode,
      onChanged: (value) => settingsProvider.setDarkMode(value),
    );
  }

  Widget _buildSearchRadiusSetting(SettingsProvider settingsProvider) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.radar),
          title: const Text('Search Radius'),
          subtitle: Text(
              '${settingsProvider.searchRadius.toStringAsFixed(1)} ${settingsProvider.unit}'),
        ),
        Slider(
          value: settingsProvider.searchRadius,
          min: 1,
          max: 100,
          divisions: 99,
          label:
              '${settingsProvider.searchRadius.toStringAsFixed(1)} ${settingsProvider.unit}',
          onChanged: (value) => settingsProvider.setSearchRadius(value),
        ),
      ],
    );
  }

  void _showLanguageDialog(SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages
              .map((language) => ListTile(
                    title: Text(language),
                    onTap: () {
                      settingsProvider.setLanguage(language);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showUnitDialog(SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _units
              .map((unit) => ListTile(
                    title: Text(unit),
                    onTap: () {
                      settingsProvider.setUnit(unit);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
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
          TextButton(
            onPressed: () {
              // TODO: Implement cache clearing
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await authProvider.deleteAccount();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting account: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
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
          TextButton(
            onPressed: () async {
              try {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }
}
