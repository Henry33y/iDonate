import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/institutions_provider.dart';

class RequestBloodPage extends StatefulWidget {
  const RequestBloodPage({super.key});

  @override
  State<RequestBloodPage> createState() => _RequestBloodPageState();
}

class _RequestBloodPageState extends State<RequestBloodPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? selectedGenotype;
  String? selectedBloodGroup;
  String? selectedUrgencyLevel;
  Map<String, dynamic>? selectedDonationCentre;
  int unitsNeeded = 1;
  bool _useGPS = false;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isSubmitting = false;

  final List<String> genotypes = ['AA', 'AS', 'SS', 'AC'];
  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  final List<String> urgencyLevels = ['Critical', 'Urgent', 'Standard'];

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
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorDialog('Location services are disabled. Please enable GPS.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorDialog('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = position;
        _currentAddress = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      _showErrorDialog('Error getting location: $e');
    }
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
                  _buildUnitsNeededField(),
                  const SizedBox(height: 20),
                  _buildDonationCentreField(),
                  const SizedBox(height: 20),
                  _buildLocationField(),
                  const SizedBox(height: 40),
                  _buildRequestButton(),
                  const SizedBox(height: 20),
                  _buildInfoSection(),
                  const SizedBox(height: 20),
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

  Widget _buildUnitsNeededField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.bloodtype, color: Colors.grey),
          ),
          const Text(
            'Units Needed:',
            style: TextStyle(color: Colors.grey),
          ),
          Expanded(
            child: Slider(
              value: unitsNeeded.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: unitsNeeded.toString(),
              onChanged: (value) {
                setState(() {
                  unitsNeeded = value.round();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              unitsNeeded.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCentreField() {
    return Consumer<InstitutionsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final institutions = provider.institutions;
        if (institutions.isEmpty) {
          return const Center(
            child: Text('No donation centres available'),
          );
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<Map<String, dynamic>>(
                value: selectedDonationCentre,
                hint: Row(
                  children: [
                    const Icon(Icons.local_hospital, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      'Select Donation Centre',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                borderRadius: BorderRadius.circular(12),
                items: institutions.map((institution) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: institution,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_hospital,
                            color: Color(0xFFCC2B2B)),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            institution['name'] ?? 'Unknown Centre',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDonationCentre = value;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentAddress ?? 'Enable GPS to get your location',
              style: TextStyle(
                color: _currentAddress != null
                    ? Colors.black87
                    : Colors.grey.shade600,
              ),
            ),
          ),
          Switch(
            value: _useGPS,
            onChanged: (value) {
              setState(() {
                _useGPS = value;
                if (value) {
                  _getCurrentLocation();
                } else {
                  _currentPosition = null;
                  _currentAddress = null;
                }
              });
            },
            activeColor: const Color(0xFFCC2B2B),
          ),
        ],
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

  Future<void> _submitRequest() async {
    if (selectedGenotype == null ||
        selectedBloodGroup == null ||
        selectedUrgencyLevel == null ||
        selectedDonationCentre == null ||
        (_useGPS && _currentPosition == null)) {
      _showErrorDialog(
          'Please fill in all fields and ensure location is enabled if using GPS');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create request data
      final requestData = {
        'userId': user.uid,
        'userEmail': user.email,
        'userName': user.displayName ?? 'Anonymous',
        'bloodType': selectedBloodGroup,
        'genotype': selectedGenotype,
        'urgency': selectedUrgencyLevel?.toLowerCase(),
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'needLocation': _useGPS
            ? {
                'lat': _currentPosition?.latitude,
                'lng': _currentPosition?.longitude,
                'label': _currentAddress,
              }
            : null,
        'donationCentre': selectedDonationCentre,
        'unitsNeeded': unitsNeeded,
        'preferredDonorSettings': {
          'minAge': 18,
          'maxAge': 65,
          'minWeight': 50,
          'minHemoglobin': 12.5,
        },
      };

      // Add to Firestore
      await FirebaseFirestore.instance.collection('requests').add(requestData);

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error submitting request: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _validateAndSubmit() {
    if (_isSubmitting) return;

    _showLoadingDialog();
    _submitRequest();
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
              const Text('Submitting your request...'),
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
