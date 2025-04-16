import 'package:flutter/material.dart';

class RequestBloodPage extends StatefulWidget {
  const RequestBloodPage({super.key});

  @override
  State<RequestBloodPage> createState() => _RequestBloodPageState();
}

class _RequestBloodPageState extends State<RequestBloodPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String? selectedGenotype;
  String? selectedBloodGroup;
  String? selectedUrgencyLevel;
  String? selectedPreferredDonor;
  final TextEditingController _locationController = TextEditingController();

  final List<String> genotypes = ['AA', 'AS', 'SS', 'AC'];
  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> urgencyLevels = ['Critical', 'Urgent', 'Standard'];
  final List<String> preferredDonors = ['Any', 'Family/Friend', 'Voluntary'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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
          'Request for Blood',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDropdownField(
                    'Genotype',
                    selectedGenotype,
                    genotypes,
                    (value) => setState(() => selectedGenotype = value),
                    Icons.biotech,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField(
                    'Blood Group',
                    selectedBloodGroup,
                    bloodGroups,
                    (value) => setState(() => selectedBloodGroup = value),
                    Icons.bloodtype,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField(
                    'Urgency Level',
                    selectedUrgencyLevel,
                    urgencyLevels,
                    (value) => setState(() => selectedUrgencyLevel = value),
                    Icons.timer,
                  ),
                  const SizedBox(height: 20),
                  _buildLocationField(),
                  const SizedBox(height: 20),
                  _buildDropdownField(
                    'Preferred Donor',
                    selectedPreferredDonor,
                    preferredDonors,
                    (value) => setState(() => selectedPreferredDonor = value),
                    Icons.person,
                  ),
                  const SizedBox(height: 40),
                  _buildRequestButton(),
                  const SizedBox(height: 20),
                  _buildInfoSection(),
                  const SizedBox(height: 20), // Add bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: value,
            hint: Row(
              children: [
                Icon(icon, color: Colors.grey),
                const SizedBox(width: 12),
                Text(label, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            isExpanded: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            borderRadius: BorderRadius.circular(12),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: const Color(0xFFCC2B2B)),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        item,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _locationController,
        decoration: InputDecoration(
          hintText: 'Location',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRequestButton() {
    return ElevatedButton(
      onPressed: _validateAndSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCC2B2B),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Request',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
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
                Flexible(
                  child: Text(
                    'Important Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Verify your location accuracy'),
            _buildInfoItem('Critical requests are prioritized'),
            _buildInfoItem('You will be notified when a donor accepts'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, color: Color(0xFFCC2B2B), size: 16),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _validateAndSubmit() {
    if (selectedGenotype == null ||
        selectedBloodGroup == null ||
        selectedUrgencyLevel == null ||
        _locationController.text.isEmpty ||
        selectedPreferredDonor == null) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    _showLoadingDialog();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Dismiss loading dialog
      _showSuccessDialog();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Error',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFFCC2B2B)),
              const SizedBox(height: 16),
              const Text('Processing your request...'),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Success',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          'Your blood request has been submitted successfully. We will notify you when a donor accepts.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 