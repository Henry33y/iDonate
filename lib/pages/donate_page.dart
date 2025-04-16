import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final bool _isEligible = true;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _lastDonationController = TextEditingController();
  String? _selectedBloodType;
  String? _selectedGender;
  bool? _hasRecentSurgery;
  bool? _hasChronicDisease;
  bool? _isPregnant;
  bool? _hasTattoo;
  DateTime? _lastMealTime;

  // Eligibility criteria
  final double _minimumWeight = 50.0; // in kg
  final int _minimumAge = 18;
  final int _maximumAge = 65;

  @override
  void dispose() {
    _pageController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _lastDonationController.dispose();
    super.dispose();
  }

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
          child: Column(
            children: [
              _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                  children: [
                  SingleChildScrollView(
                    child: _buildEligibilityCheck(),
                  ),
                  SingleChildScrollView(
                    child: _buildPersonalInfo(),
                  ),
                  SingleChildScrollView(
                    child: _buildHealthQuestionnaire(),
                  ),
                  SingleChildScrollView(
                    child: _buildDonationPreferences(),
                  ),
                  SingleChildScrollView(
                    child: _buildConfirmation(),
                  ),
                  ],
                ),
              ),
            ],
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

  Widget _buildProgressIndicator() {
    return Container(
          padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepCircle(0, 'Eligibility'),
              _buildStepLine(0),
              _buildStepCircle(1, 'Personal Info'),
              _buildStepLine(1),
              _buildStepCircle(2, 'Health'),
              _buildStepLine(2),
              _buildStepCircle(3, 'Preferences'),
              _buildStepLine(3),
              _buildStepCircle(4, 'Confirm'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getStepTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
                children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFCC2B2B) : Colors.grey[300],
          ),
          child: Center(
            child: Icon(
              _getStepIcon(step),
              size: 16,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFFCC2B2B) : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFFCC2B2B) : Colors.grey[300],
      ),
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 0:
        return Icons.check_circle;
      case 1:
        return Icons.person;
      case 2:
        return Icons.favorite;
      case 3:
        return Icons.settings;
      case 4:
        return Icons.done_all;
      default:
        return Icons.circle;
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Check Eligibility';
      case 1:
        return 'Personal Information';
      case 2:
        return 'Health Questionnaire';
      case 3:
        return 'Donation Preferences';
      case 4:
        return 'Confirm Details';
      default:
        return '';
    }
  }

  Widget _buildEligibilityCheck() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _ageController,
              label: 'Age',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your age';
                }
                final age = int.tryParse(value);
                if (age == null || age < _minimumAge || age > _maximumAge) {
                  return 'Age must be between $_minimumAge and $_maximumAge';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _weightController,
              label: 'Weight (kg)',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your weight';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight < _minimumWeight) {
                  return 'Weight must be at least $_minimumWeight kg';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _lastDonationController,
              label: 'Last Donation Date (if any)',
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  _lastDonationController.text = DateFormat('yyyy-MM-dd').format(date);
                }
              },
            ),
            const SizedBox(height: 24),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown(
            label: 'Blood Type',
            value: _selectedBloodType,
            items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
            onChanged: (value) => setState(() => _selectedBloodType = value),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Gender',
            value: _selectedGender,
            items: ['Male', 'Female', 'Other'],
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: () => _previousStep(),
                child: const Text('Back'),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildNextButton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthQuestionnaire() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildYesNoQuestion(
            'Have you had any surgery in the last 6 months?',
            _hasRecentSurgery,
            (value) => setState(() => _hasRecentSurgery = value),
          ),
          _buildYesNoQuestion(
            'Do you have any chronic diseases?',
            _hasChronicDisease,
            (value) => setState(() => _hasChronicDisease = value),
          ),
          if (_selectedGender == 'Female')
            _buildYesNoQuestion(
              'Are you pregnant or have been pregnant in the last 6 months?',
              _isPregnant,
              (value) => setState(() => _isPregnant = value),
            ),
          _buildYesNoQuestion(
            'Have you gotten a tattoo or piercing in the last 6 months?',
            _hasTattoo,
            (value) => setState(() => _hasTattoo = value),
          ),
          const SizedBox(height: 16),
          Text(
            'When was your last meal?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _lastMealTime = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            },
            icon: const Icon(Icons.access_time),
            label: Text(
              _lastMealTime != null
                  ? DateFormat('hh:mm a').format(_lastMealTime!)
                  : 'Select Time',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: () => _previousStep(),
                child: const Text('Back'),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildNextButton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonationPreferences() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            'Donation Center Preferences',
          style: TextStyle(
              fontSize: 18,
            fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPreferenceCard(
            'City General Hospital',
            '123 Main Street',
            '2.5 km away',
            4.5,
          ),
          _buildPreferenceCard(
            'Red Cross Blood Bank',
            '456 Park Avenue',
            '3.8 km away',
            4.8,
          ),
          _buildPreferenceCard(
            'Community Health Center',
            '789 Oak Road',
            '5.2 km away',
            4.2,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: () => _previousStep(),
                child: const Text('Back'),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildNextButton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConfirmationCard(),
          const SizedBox(height: 24),
          const Text(
            'Important Notes:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
          _buildNoteItem('Please bring a valid ID'),
          _buildNoteItem('Eat well before donation'),
          _buildNoteItem('Get adequate rest'),
          _buildNoteItem('Wear comfortable clothing'),
          const SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: () => _previousStep(),
                child: const Text('Back'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitDonation,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCC2B2B),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
                    'Confirm Donation',
            style: TextStyle(
                      color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
                ),
              ),
            ],
        ),
      ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
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
                Icon(Icons.info_outline, color: Color(0xFFCC2B2B)),
                SizedBox(width: 8),
                Text(
                  'Basic Requirements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRequirementItem('Age between 18-65 years'),
            _buildRequirementItem('Weight above 50 kg'),
            _buildRequirementItem('Good health condition'),
            _buildRequirementItem('No recent major surgery'),
            _buildRequirementItem('No current medications'),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFCC2B2B), size: 16),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCC2B2B)),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(12),
              hint: Text(label),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYesNoQuestion(
    String question,
    bool? value,
    void Function(bool?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: value,
              onChanged: onChanged,
              activeColor: const Color(0xFFCC2B2B),
            ),
            const Text('Yes'),
            const SizedBox(width: 16),
            Radio<bool>(
              value: false,
              groupValue: value,
              onChanged: onChanged,
              activeColor: const Color(0xFFCC2B2B),
            ),
            const Text('No'),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildPreferenceCard(
    String name,
    String address,
    String distance,
    double rating,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile<String>(
        value: name,
        groupValue: 'City General Hospital', // Replace with actual selected value
        onChanged: (value) {
          // Handle selection
        },
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(address),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  distance,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donation Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Blood Type', _selectedBloodType ?? 'Not specified'),
            _buildDetailRow('Age', _ageController.text),
            _buildDetailRow('Weight', '${_weightController.text} kg'),
            _buildDetailRow('Gender', _selectedGender ?? 'Not specified'),
            _buildDetailRow(
              'Location',
              'City General Hospital, 123 Main Street',
            ),
            _buildDetailRow(
              'Last Meal',
              _lastMealTime != null
                  ? DateFormat('hh:mm a').format(_lastMealTime!)
                  : 'Not specified',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                Text(
            value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFCC2B2B), size: 16),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: _nextStep,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCC2B2B),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                Text(
            _currentStep == 4 ? 'Confirm' : 'Next',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_currentStep < 4) ...[
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) {
      return;
    }

    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _submitDonation() {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFCC2B2B),
        ),
      ),
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Dismiss loading indicator
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Thank You!'),
          ],
        ),
        content: const Text(
          'Your blood donation request has been submitted successfully. We will send you a confirmation email with further instructions.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Dismiss dialog
              Navigator.pop(context); // Return to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC2B2B),
            ),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
} 