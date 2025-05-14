import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                      'iDonate App Privacy Policy',
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
                'Introduction',
                'At iDonate, we are committed to protecting and respecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your personal information when you use our mobile application and related services ("Service"). By using the iDonate app, you agree to the collection and use of information in accordance with this policy.',
                theme,
              ),
              _buildSection(
                '1. Information We Collect',
                'To provide you with a smooth experience, we collect the following types of information:\n\n'
                'Personal Information: This includes data you provide when registering or using the app, such as your name (optional), email address, phone number (optional), and blood type.\n\n'
                'Location Information: We collect your location data to help connect you with nearby blood donation centers and facilitate location-based services.\n\n'
                'Usage Data: We collect information on how you use the app, such as the features you access, the time you spend using them, and interaction patterns. This helps us improve the app\'s functionality and user experience.',
                theme,
              ),
              _buildSection(
                '2. How We Use Your Information',
                'We use the information we collect in the following ways:\n\n'
                'To Provide Services: To facilitate blood donation, connect donors and recipients, and display nearby donation centers.\n\n'
                'To Improve the App: We use usage data to analyze trends, fix bugs, and enhance the app\'s overall performance.\n\n'
                'Emergency Features: If you use the panic alert feature, your location and the alert signal will be sent to your emergency contacts or authorities, as necessary.\n\n'
                'To Communicate with You: We may send you updates about the app, such as new features, maintenance schedules, or important changes to the Terms of Service and Privacy Policy.\n\n'
                'Legal Compliance: We may use your information to comply with applicable laws, regulations, or legal processes.',
                theme,
              ),
              _buildSection(
                '3. Data Retention',
                'We retain your personal data only as long as necessary for the purposes outlined in this Privacy Policy or as required by law. You can request to have your data deleted at any time through the app\'s settings, or by contacting support.',
                theme,
              ),
              _buildSection(
                '4. Data Security',
                'We take the security of your personal data seriously and implement appropriate measures to protect it from unauthorized access, disclosure, alteration, and destruction. These measures include:\n\n'
                'Encryption: All sensitive data is encrypted both in transit (using TLS) and at rest (using AES-256).\n\n'
                'Access Control: Only authorized personnel have access to your data, and we employ role-based access to ensure data is accessible only to those who need it.\n\n'
                'Security Audits: We perform regular security audits and vulnerability assessments to maintain a high level of data protection.',
                theme,
              ),
              _buildSection(
                '5. Data Sharing',
                'We do not sell or rent your personal information to third parties. However, we may share your information under the following circumstances:\n\n'
                'Service Providers: We may share your information with third-party service providers who assist us in operating the app and providing services (e.g., cloud storage providers). These providers are obligated to keep your information confidential.\n\n'
                'Legal Requirements: If required by law, we may share your information with authorities or in response to legal requests (such as subpoenas, court orders, or legal processes).\n\n'
                'Aggregated Data: We may use and share aggregated, non-identifiable data for research, analysis, or public health studies. This data will not contain any personal identifiers.',
                theme,
              ),
              _buildSection(
                '6. User Rights',
                'You have the following rights regarding your personal information:\n\n'
                'Access: You have the right to access the personal data we hold about you.\n\n'
                'Correction: You have the right to request corrections to any inaccurate or incomplete personal data.\n\n'
                'Deletion: You can request to delete your personal data at any time through the app or by contacting us directly.\n\n'
                'Objection: You have the right to object to the processing of your personal data in certain circumstances.\n\n'
                'To exercise these rights, please contact us at support@idonateapp.org.',
                theme,
              ),
              _buildSection(
                '7. Children\'s Privacy',
                'iDonate is not intended for children under the age of 13. We do not knowingly collect or solicit personal information from children under 13. If we learn that we have inadvertently collected personal information from a child under 13, we will take steps to delete that information as soon as possible.',
                theme,
              ),
              _buildSection(
                '8. Third-Party Links',
                'The iDonate app may contain links to external websites or services. We are not responsible for the privacy practices or the content of third-party sites. We encourage you to review the privacy policies of any third-party services you visit.',
                theme,
              ),
              _buildSection(
                '9. Changes to This Privacy Policy',
                'We reserve the right to update or modify this Privacy Policy at any time. If we make changes, the updated policy will be posted in the app or on our website. We will also notify users of significant changes where applicable. Your continued use of the app after the updated Privacy Policy has been posted constitutes your acceptance of the changes.',
                theme,
              ),
              _buildSection(
                '10. Contact Us',
                'If you have any questions or concerns about this Privacy Policy, or if you wish to exercise your privacy rights, please contact us at:\n\n'
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