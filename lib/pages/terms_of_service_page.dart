import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: const Color(0xFFCC2B2B),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC2B2B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'iDonate App Terms of Service',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFFCC2B2B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Effective Date: March 19, 2024',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                '1. Introduction',
                'Welcome to iDonate! These Terms of Service ("Terms") govern your use of the iDonate mobile application and related services ("Service"). By downloading, accessing, or using iDonate, you agree to comply with these Terms. If you do not agree to these Terms, please do not use the Service.',
                theme,
              ),
              _buildSection(
                '2. Purpose of the App',
                'iDonate is designed to connect blood donors, recipients, hospitals, and blood banks to facilitate blood donations and emergency medical needs. The app also includes a panic alert feature that helps users send distress signals in emergency situations.',
                theme,
              ),
              _buildSection(
                '3. User Eligibility',
                'To use iDonate, you must:\n\n'
                    '• Be at least 18 years old or have the consent of a parent or legal guardian to use the app.\n'
                    '• Provide accurate, up-to-date information when creating your account.\n'
                    '• Agree to the terms and conditions outlined in this agreement.\n\n'
                    'If you do not meet these requirements, you may not use the app.',
                theme,
              ),
              _buildSection(
                '4. Account Creation and Privacy',
                'Account: Users must create an account to access the app\'s features. Personal information such as your name, contact details, and blood type may be required. However, iDonate allows users to remain anonymous by using unique identifiers instead of real names.\n\n'
                    'Privacy: Your use of the Service is also governed by the iDonate Privacy Policy. Please review it to understand how your personal information is collected, used, and protected.\n\n'
                    'Account Security: You are responsible for safeguarding your login credentials and ensuring the security of your device. Notify us immediately if you believe your account has been compromised.',
                theme,
              ),
              _buildSection(
                '5. Acceptable Use',
                'By using iDonate, you agree not to:\n\n'
                    '• Use the app for any illegal, fraudulent, or harmful activities.\n'
                    '• Misuse the panic alert feature (e.g., sending false alarms).\n'
                    '• Attempt to hack, disrupt, or bypass the security measures of the app.\n'
                    '• Impersonate any person or entity or misrepresent your affiliation with any entity.',
                theme,
              ),
              _buildSection(
                '6. Emergency Features',
                'iDonate provides emergency features, including:\n\n'
                    'Panic Alerts: Users can trigger emergency alerts through intuitive gestures, such as double or triple tapping the volume or power button. These alerts send distress signals to selected emergency contacts and, in some cases, authorities.\n\n'
                    'Audio Recording: In emergency situations, the app may record audio as evidence. This data is encrypted and stored locally until uploaded with user consent or when a critical event occurs.\n\n'
                    'Misuse of emergency features may result in the suspension or termination of your account.',
                theme,
              ),
              _buildSection(
                '7. Data Usage and Consent',
                'Data Collection: By using iDonate, you consent to the collection of minimal personal and location data necessary for the functionality of the app (such as blood type, donation history, location data for nearby centers).\n\n'
                    'Data Sharing: We do not share your data with third parties unless explicitly authorized by you, or if required by law. For public health or research purposes, only aggregated and anonymized data will be shared.\n\n'
                    'Third-Party Services: iDonate may link to third-party websites or services. We are not responsible for the content or privacy practices of these third parties.',
                theme,
              ),
              _buildSection(
                '8. Termination and Suspension',
                'We reserve the right to suspend or terminate your access to the app at our sole discretion:\n\n'
                    '• If you violate these Terms.\n'
                    '• If we believe your account or activities pose a risk to the security of the app or the safety of its users.\n'
                    '• If you fail to comply with applicable laws and regulations.\n\n'
                    'You may also deactivate or delete your account at any time by following the instructions in the app settings.',
                theme,
              ),
              _buildSection(
                '9. Intellectual Property',
                'All content, including text, graphics, logos, and features, within iDonate are the property of iDonate or its licensors and are protected by copyright, trademark, and other intellectual property laws. Unauthorized use or reproduction is prohibited.',
                theme,
              ),
              _buildSection(
                '10. Disclaimer of Warranties',
                'The app and its services are provided "as is" and "as available." iDonate does not warrant that the app will be error-free, secure, or uninterrupted. We make no representations or warranties of any kind, either express or implied, regarding the app\'s functionality, performance, or availability.',
                theme,
              ),
              _buildSection(
                '11. Limitation of Liability',
                'To the fullest extent permitted by law, iDonate will not be liable for any direct, indirect, incidental, or consequential damages arising from your use or inability to use the app, including but not limited to loss of data, loss of income, or personal injury.',
                theme,
              ),
              _buildSection(
                '12. Governing Law',
                'These Terms are governed by the laws of the Republic of Ghana. Any legal actions related to these Terms shall be brought before the courts in Ghana.',
                theme,
              ),
              _buildSection(
                '13. Changes to the Terms',
                'We reserve the right to modify or update these Terms at any time. If changes are made, the updated Terms will be posted on the app or website. Continued use of the app after such changes constitutes your acceptance of the revised Terms.',
                theme,
              ),
              _buildSection(
                '14. Contact Us',
                'For questions or concerns regarding these Terms, please contact us at:\n\n'
                    'Email: support@idonateapp.org\n'
                    'Phone: +233550325368\n'
                    'Website: www.idonateapp.org',
                theme,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFFCC2B2B),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
