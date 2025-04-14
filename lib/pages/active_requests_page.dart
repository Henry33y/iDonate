import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActiveRequestsPage extends StatefulWidget {
  const ActiveRequestsPage({super.key});

  @override
  State<ActiveRequestsPage> createState() => _ActiveRequestsPageState();
}

class _ActiveRequestsPageState extends State<ActiveRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _isMapView = false;

  // Simulated data
  final List<BloodRequest> _requests = [
    BloodRequest(
      patientName: "Sarah Johnson",
      bloodType: "A+",
      unitsNeeded: 2,
      hospital: "City General Hospital",
      location: "123 Main Street, Downtown",
      urgency: RequestUrgency.critical,
      timePosted: DateTime.now().subtract(const Duration(hours: 2)),
      distance: 2.5,
      contactNumber: "+1234567890",
      additionalInfo: "Patient needs blood for emergency surgery",
      status: RequestStatus.active,
    ),
    BloodRequest(
      patientName: "Michael Brown",
      bloodType: "O-",
      unitsNeeded: 3,
      hospital: "St. Mary's Medical Center",
      location: "456 Park Avenue, Midtown",
      urgency: RequestUrgency.urgent,
      timePosted: DateTime.now().subtract(const Duration(hours: 5)),
      distance: 3.8,
      contactNumber: "+1234567891",
      additionalInfo: "Regular transfusion needed for thalassemia patient",
      status: RequestStatus.active,
    ),
    BloodRequest(
      patientName: "Emma Wilson",
      bloodType: "B+",
      unitsNeeded: 1,
      hospital: "Community Health Center",
      location: "789 Oak Road, Westside",
      urgency: RequestUrgency.standard,
      timePosted: DateTime.now().subtract(const Duration(days: 1)),
      distance: 1.2,
      contactNumber: "+1234567892",
      additionalInfo: "Scheduled surgery next week",
      status: RequestStatus.fulfilled,
    ),
    // Add more requests as needed
  ];

  List<BloodRequest> get filteredRequests {
    return _requests.where((request) {
      if (_selectedFilter != 'All' && request.bloodType != _selectedFilter) {
        return false;
      }
      final searchTerm = _searchController.text.toLowerCase();
      if (searchTerm.isEmpty) return true;
      
      return request.patientName.toLowerCase().contains(searchTerm) ||
             request.hospital.toLowerCase().contains(searchTerm) ||
             request.location.toLowerCase().contains(searchTerm);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        title: const Text(
          'Active Requests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            color: Colors.white,
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
            ],
          ),
        ),
      ),
      body: _isMapView ? _buildMapView() : _buildListView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create request page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create request feature coming soon!')),
          );
        },
        backgroundColor: const Color(0xFFCC2B2B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Request',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search requests...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white24,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    final bloodTypes = ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: bloodTypes.length,
        itemBuilder: (context, index) {
          final type = bloodTypes[index];
          final isSelected = _selectedFilter == type;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: isSelected,
              label: Text(type),
              onSelected: (selected) {
                setState(() => _selectedFilter = type);
              },
              backgroundColor: Colors.white24,
              selectedColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFCC2B2B) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    if (filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No requests found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) {
        final request = filteredRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(BloodRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showRequestDetails(request),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            _buildRequestHeader(request),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        request.patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.local_hospital, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.hospital,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${request.location} (${request.distance.toStringAsFixed(1)} km)',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTimeAgo(request.timePosted),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (request.status == RequestStatus.active)
                        ElevatedButton(
                          onPressed: () => _respondToRequest(request),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCC2B2B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Respond',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestHeader(BloodRequest request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getUrgencyColor(request.urgency).withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC2B2B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.bloodType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${request.unitsNeeded} units needed',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _buildUrgencyChip(request.urgency),
        ],
      ),
    );
  }

  Widget _buildUrgencyChip(RequestUrgency urgency) {
    final color = _getUrgencyColor(urgency);
    final text = _getUrgencyText(urgency);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            urgency == RequestUrgency.critical
                ? Icons.warning
                : Icons.info_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(RequestUrgency urgency) {
    switch (urgency) {
      case RequestUrgency.critical:
        return Colors.red;
      case RequestUrgency.urgent:
        return Colors.orange;
      case RequestUrgency.standard:
        return Colors.blue;
    }
  }

  String _getUrgencyText(RequestUrgency urgency) {
    switch (urgency) {
      case RequestUrgency.critical:
        return 'Critical';
      case RequestUrgency.urgent:
        return 'Urgent';
      case RequestUrgency.standard:
        return 'Standard';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  Widget _buildMapView() {
    // Placeholder for map view
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Map view coming soon!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(BloodRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Request Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildUrgencyChip(request.urgency),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Patient', request.patientName),
            _buildDetailRow('Blood Type', request.bloodType),
            _buildDetailRow('Units Needed', request.unitsNeeded.toString()),
            _buildDetailRow('Hospital', request.hospital),
            _buildDetailRow('Location', request.location),
            _buildDetailRow('Distance', '${request.distance.toStringAsFixed(1)} km'),
            _buildDetailRow('Posted', _formatTimeAgo(request.timePosted)),
            _buildDetailRow('Contact', request.contactNumber),
            if (request.additionalInfo != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Additional Information:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(request.additionalInfo!),
            ],
            const SizedBox(height: 24),
            if (request.status == RequestStatus.active)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFCC2B2B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Color(0xFFCC2B2B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _respondToRequest(request);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC2B2B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Respond',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _respondToRequest(BloodRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Response'),
        content: Text(
          'Are you sure you want to respond to the blood request from ${request.patientName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showResponseConfirmation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC2B2B),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showResponseConfirmation() {
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
          'Your response has been recorded. The hospital will contact you shortly with further instructions.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
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

enum RequestUrgency {
  critical,
  urgent,
  standard,
}

enum RequestStatus {
  active,
  fulfilled,
  cancelled,
}

class BloodRequest {
  final String patientName;
  final String bloodType;
  final int unitsNeeded;
  final String hospital;
  final String location;
  final RequestUrgency urgency;
  final DateTime timePosted;
  final double distance;
  final String contactNumber;
  final String? additionalInfo;
  final RequestStatus status;

  BloodRequest({
    required this.patientName,
    required this.bloodType,
    required this.unitsNeeded,
    required this.hospital,
    required this.location,
    required this.urgency,
    required this.timePosted,
    required this.distance,
    required this.contactNumber,
    this.additionalInfo,
    required this.status,
  });
} 