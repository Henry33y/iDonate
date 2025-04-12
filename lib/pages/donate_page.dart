import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  bool _isEligible = true;
  final List<String> _eligibilityQuestions = [
    'Are you between 18-65 years old?',
    'Is your weight above 50kg?',
    'Have you had enough sleep last night?',
    'Have you eaten in the last 4 hours?',
    'Are you free from any infections or illnesses?',
    'Have you not donated blood in the last 3 months?',
  ];
  final List<bool?> _answers = List.filled(6, null);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        elevation: 0,
        title: const Text(
          'Donate Blood',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode 
              ? [const Color(0xFF1F1F1F), const Color(0xFF121212)]
              : [Colors.white, const Color(0xFFF5F5F5)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eligibility Check',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._buildEligibilityQuestions(),
                    const SizedBox(height: 24),
                    if (_isEligible && _answers.every((answer) => answer == true))
                      _buildDonationOptions(),
                    const SizedBox(height: 24),
                    _buildImportantInfo(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCC2B2B),
            Color(0xFFE53935),
          ],
        ),
      ),
      child: Column(
        children: [
          const Icon(
            FontAwesomeIcons.handHoldingMedical,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Save Lives',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your donation can save up to 3 lives',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEligibilityQuestions() {
    return List.generate(_eligibilityQuestions.length, (index) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _eligibilityQuestions[index],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Row(
                children: [
                  _buildAnswerButton(
                    index,
                    true,
                    Icons.check_circle,
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildAnswerButton(
                    index,
                    false,
                    Icons.cancel,
                    Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAnswerButton(int index, bool value, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _answers[index] = value;
          _isEligible = _answers.every((answer) => answer == true);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _answers[index] == value ? color.withOpacity(0.1) : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: _answers[index] == value ? color : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDonationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'You are eligible to donate!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement donation scheduling
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Scheduling feature coming soon!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCC2B2B),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Schedule Donation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImportantInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Color(0xFFCC2B2B)),
                SizedBox(width: 8),
                Text(
                  'Important Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              'Bring valid ID',
              'Please bring a government-issued photo ID',
              Icons.card_membership,
            ),
            _buildInfoItem(
              'Eat & Drink',
              'Eat well and drink plenty of water before donation',
              Icons.restaurant,
            ),
            _buildInfoItem(
              'Get Rest',
              'Ensure you get adequate sleep the night before',
              Icons.bed,
            ),
            _buildInfoItem(
              'Wear Comfortable',
              'Wear clothing with sleeves that can be raised above the elbow',
              Icons.checkroom,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFCC2B2B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFCC2B2B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 