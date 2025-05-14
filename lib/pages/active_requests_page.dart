import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/blood_requests_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/request_card.dart';
import '../widgets/request_map.dart';
import '../utils/theme.dart';
import '../pages/appointment_page.dart';

class ActiveRequestsPage extends StatefulWidget {
  const ActiveRequestsPage({super.key});

  @override
  State<ActiveRequestsPage> createState() => _ActiveRequestsPageState();
}

class _ActiveRequestsPageState extends State<ActiveRequestsPage> {
  bool _isMapView = false;
  String _searchQuery = '';
  String _selectedBloodGroup = 'All';
  String _selectedUrgency = 'All';
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  double? _calculateDistance(Map<String, dynamic>? needLocation) {
    if (_currentPosition == null || needLocation == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      needLocation['lat'] ?? 0.0,
      needLocation['lng'] ?? 0.0,
    );
  }

  String _formatDistance(double? meters) {
    if (meters == null) return 'Distance unknown';
    if (meters < 1000) {
      return '${meters.round()}m away';
    }
    return '${(meters / 1000).toStringAsFixed(1)}km away';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Requests'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
        ],
      ),
      body: Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
          Expanded(
            child: Consumer<BloodRequestsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.requests.isEmpty) {
                  return const Center(
                    child: Text('No active requests found'),
                  );
                }

                var filteredRequests = provider.requests.where((request) {
                  final matchesSearch = request.userName
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      request.bloodGroup
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      request.genotype
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());

                  final matchesBloodGroup = _selectedBloodGroup == 'All' ||
                      request.bloodGroup == _selectedBloodGroup;

                  final matchesUrgency = _selectedUrgency == 'All' ||
                      request.urgencyLevel.toString().split('.').last ==
                          _selectedUrgency.toLowerCase();

                  return matchesSearch && matchesBloodGroup && matchesUrgency;
                }).toList();

                if (filteredRequests.isEmpty) {
                  return const Center(
                    child: Text('No requests match your filters'),
                  );
                }

                return _isMapView
                    ? RequestMap(requests: filteredRequests)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          final request = filteredRequests[index];
                          return RequestCard(
                            request: request,
                            onRespond: () => _handleRespond(request),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by name, blood group, or genotype',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All',
            isSelected: _selectedBloodGroup == 'All',
            onSelected: (selected) {
              setState(() {
                _selectedBloodGroup = 'All';
              });
            },
          ),
          ...['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map(
            (group) => _buildFilterChip(
              label: group,
              isSelected: _selectedBloodGroup == group,
              onSelected: (selected) {
                setState(() {
                  _selectedBloodGroup = group;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          _buildFilterChip(
            label: 'All',
            isSelected: _selectedUrgency == 'All',
            onSelected: (selected) {
              setState(() {
                _selectedUrgency = 'All';
              });
            },
          ),
          ...['Critical', 'Urgent', 'Standard'].map(
            (urgency) => _buildFilterChip(
              label: urgency,
              isSelected: _selectedUrgency == urgency,
              onSelected: (selected) {
                setState(() {
                  _selectedUrgency = urgency;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Future<void> _handleRespond(BloodRequest request) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to respond to requests'),
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Response'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to respond to ${request.userName}\'s request for ${request.bloodGroup} blood?',
              ),
              const SizedBox(height: 8),
            Text(
              'Donation Centre: ${request.donationCentre?['name'] ?? 'Not specified'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final firestore = FirebaseFirestore.instance;

      // Start a batch write
      final batch = firestore.batch();

      // Create the appointment document
      final appointmentRef = firestore.collection('appointments').doc();
      batch.set(appointmentRef, {
        'appointmentId': appointmentRef.id,
        'requestId': request.id,
        'donorId': user.uid,
        'donorName': user.displayName ?? 'Anonymous',
        'donorEmail': user.email,
        'donationCentre': request.donationCentre,
        'appointmentDate': null,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the request status
      final requestRef = firestore.collection('requests').doc(request.id);
      batch.update(requestRef, {
        'status': 'pending',
        'acceptedBy': user.uid,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Request accepted. Please schedule your appointment.'),
          ),
        );
        // Navigate to appointment scheduling page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AppointmentPage(
              appointmentId: appointmentRef.id,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
      ),
    );
  }
}
  }
}
