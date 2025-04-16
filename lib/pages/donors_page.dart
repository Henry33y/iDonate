import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DonorsPage extends StatefulWidget {
  const DonorsPage({super.key});

  @override
  State<DonorsPage> createState() => _DonorsPageState();
}

class _DonorsPageState extends State<DonorsPage> {
  String _selectedBloodType = 'All';
  double _maxDistance = 10.0;
  bool _onlyAvailable = true;
  final TextEditingController _searchController = TextEditingController();

  // Simulated donor data
  final List<Donor> _donors = [
    Donor(
      id: 'XN56',
      genotype: 'AS',
      bloodGroup: 'A+',
      distance: 6,
      contact: '+2348109827',
      address: '123 Main Street, Downtown Area',
      lastDonation: DateTime.now().subtract(const Duration(days: 95)),
      isAvailable: true,
      rating: 4.8,
      donationCount: 12,
    ),
    Donor(
      id: 'XN57',
      genotype: 'AA',
      bloodGroup: 'O+',
      distance: 3.5,
      contact: '+2348109828',
      address: '456 Park Avenue, Uptown District',
      lastDonation: DateTime.now().subtract(const Duration(days: 45)),
      isAvailable: false,
      rating: 4.5,
      donationCount: 8,
    ),
    // Add more donors as needed
  ];

  List<Donor> get filteredDonors {
    return _donors.where((donor) {
      if (_onlyAvailable && !donor.isAvailable) return false;
      if (donor.distance > _maxDistance) return false;
      if (_selectedBloodType != 'All' && donor.bloodGroup != _selectedBloodType) return false;
      
      final searchTerm = _searchController.text.toLowerCase();
      if (searchTerm.isEmpty) return true;
      
      return donor.id.toLowerCase().contains(searchTerm) ||
             donor.address.toLowerCase().contains(searchTerm);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        title: const Text(
          "Donor's List",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildFilters(),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildDistanceSlider(),
            Expanded(
              child: filteredDonors.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDonors.length,
                      itemBuilder: (context, index) {
                        return _buildDonorCard(filteredDonors[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Become a donor feature coming soon!')),
          );
        },
        backgroundColor: const Color(0xFFCC2B2B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Become a Donor',
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
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search donors...',
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
      ),
    );
  }

  Widget _buildFilters() {
    final bloodTypes = ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: bloodTypes.length,
              itemBuilder: (context, index) {
                final type = bloodTypes[index];
                final isSelected = _selectedBloodType == type;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(type),
                    onSelected: (selected) {
                      setState(() => _selectedBloodType = type);
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
          ),
          const SizedBox(width: 8),
          FilterChip(
            selected: _onlyAvailable,
            label: const Text('Available'),
            onSelected: (selected) {
              setState(() => _onlyAvailable = selected);
            },
            backgroundColor: Colors.white24,
            selectedColor: Colors.white,
            labelStyle: TextStyle(
              color: _onlyAvailable ? const Color(0xFFCC2B2B) : Colors.white,
            ),
            avatar: Icon(
              Icons.check_circle,
              color: _onlyAvailable ? const Color(0xFFCC2B2B) : Colors.white70,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Maximum Distance',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_maxDistance.toStringAsFixed(1)} km',
                style: const TextStyle(
                  color: Color(0xFFCC2B2B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFCC2B2B),
              inactiveTrackColor: const Color(0xFFCC2B2B).withOpacity(0.2),
              thumbColor: const Color(0xFFCC2B2B),
              overlayColor: const Color(0xFFCC2B2B).withOpacity(0.1),
              valueIndicatorColor: const Color(0xFFCC2B2B),
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: Slider(
              value: _maxDistance,
              min: 1,
              max: 50,
              divisions: 49,
              label: '${_maxDistance.toStringAsFixed(1)} km',
              onChanged: (value) {
                setState(() => _maxDistance = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorCard(Donor donor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDonorDetails(donor),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Donor #${donor.id}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: donor.isAvailable ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: donor.isAvailable ? Colors.green : Colors.grey,
                            ),
                          ),
                          child: Text(
                            donor.isAvailable ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              color: donor.isAvailable ? Colors.green : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 20),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag, size: 20),
                            SizedBox(width: 8),
                            Text('Report'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$value feature coming soon!')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildInfoChip('Genotype', donor.genotype),
                    const SizedBox(width: 8),
                    _buildInfoChip('Blood Group', donor.bloodGroup),
                    const SizedBox(width: 8),
                    _buildInfoChip('Distance', '${donor.distance}km away'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      donor.address,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          donor.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.bloodtype, size: 16, color: Color(0xFFCC2B2B)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${donor.donationCount} donations',
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () => _showMessageDialog(donor),
                          icon: const Icon(Icons.message, size: 16),
                          label: const Text('Message'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFCC2B2B),
                            side: const BorderSide(color: Color(0xFFCC2B2B)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: () => _showCallDialog(donor),
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCC2B2B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFCC2B2B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFCC2B2B),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'No donors found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showDonorDetails(Donor donor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Donor #${donor.id}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: donor.isAvailable ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: donor.isAvailable ? Colors.green : Colors.grey,
                    ),
                  ),
                  child: Text(
                    donor.isAvailable ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      color: donor.isAvailable ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Genotype', donor.genotype),
            _buildDetailRow('Blood Group', donor.bloodGroup),
            _buildDetailRow('Distance', '${donor.distance}km away'),
            _buildDetailRow('Address', donor.address),
            _buildDetailRow('Last Donation', _formatDate(donor.lastDonation)),
            _buildDetailRow('Rating', '${donor.rating} / 5.0'),
            _buildDetailRow('Total Donations', donor.donationCount.toString()),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showMessageDialog(donor);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFCC2B2B)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Message',
                      style: TextStyle(color: Color(0xFFCC2B2B)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCallDialog(donor);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC2B2B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Call',
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
            width: 120,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showMessageDialog(Donor donor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message Donor #${donor.id}'),
        content: const Text(
          'Would you like to send a message to this donor?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to messaging screen or show messaging interface
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Messaging feature coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC2B2B),
            ),
            child: const Text(
              'Message',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(Donor donor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call Donor #${donor.id}'),
        content: Text(
          'Would you like to call ${donor.contact}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Launch phone call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call feature coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC2B2B),
            ),
            child: const Text(
              'Call',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class Donor {
  final String id;
  final String genotype;
  final String bloodGroup;
  final double distance;
  final String contact;
  final String address;
  final DateTime lastDonation;
  final bool isAvailable;
  final double rating;
  final int donationCount;

  Donor({
    required this.id,
    required this.genotype,
    required this.bloodGroup,
    required this.distance,
    required this.contact,
    required this.address,
    required this.lastDonation,
    required this.isAvailable,
    required this.rating,
    required this.donationCount,
  });
} 