import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class DonationCentersPage extends StatefulWidget {
  const DonationCentersPage({super.key});

  @override
  State<DonationCentersPage> createState() => _DonationCentersPageState();
}

class _DonationCentersPageState extends State<DonationCentersPage> {
  GoogleMapController? _mapController;
  bool _isListView = false;
  String _selectedFilter = 'All Centers';
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;
  List<Map<String, dynamic>> _filteredCenters = [];
  bool _isLoading = true;
  Set<Marker> _markers = {};
  LatLng _center = const LatLng(37.7749, -122.4194); // Default center

  final List<String> _filters = [
    'All Centers',
    'Nearest',
    'Available Now',
    'Hospitals',
    'Blood Banks'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadCenters();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = position;
        _center = LatLng(position.latitude, position.longitude);
      });

      // Update map camera if controller is available
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _center,
              zoom: 13,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _loadCenters() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('institutions').get();

      final List<Map<String, dynamic>> centers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'type': data['type'] ?? 'Unknown',
          'address': data['address'] ?? 'No address',
          'rating': (data['rating'] ?? 0.0).toDouble(),
          'reviews': data['reviews'] ?? 0,
          'status': data['isOpen'] ? 'Open' : 'Closed',
          'hours': data['hours'] ?? 'Not specified',
          'phone': data['phone'] ?? 'Not available',
          'website': data['website'] ?? 'Not available',
          'position': LatLng(
            data['location']?['latitude'] ?? 0.0,
            data['location']?['longitude'] ?? 0.0,
          ),
          'services': List<String>.from(data['services'] ?? []),
          'bloodTypes': List<String>.from(data['bloodTypes'] ?? []),
          'waitTime': data['waitTime'] ?? 'Not available',
          'distance': _calculateDistance(
            _currentPosition?.latitude ?? 0.0,
            _currentPosition?.longitude ?? 0.0,
            data['location']?['latitude'] ?? 0.0,
            data['location']?['longitude'] ?? 0.0,
          ).toStringAsFixed(1),
        };
      }).toList();

      setState(() {
        _filteredCenters = centers;
        _updateMarkers();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading centers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMarkers() {
    if (!mounted) return;

    setState(() {
      _markers = _filteredCenters.map((center) {
        return Marker(
          markerId: MarkerId(center['id']),
          position: center['position'],
          infoWindow: InfoWindow(
            title: center['name'],
            snippet: '${center['type']} • ${center['distance']} km',
          ),
          onTap: () {
            _showCenterDetails(center);
          },
        );
      }).toSet();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
      _updateMarkers();
    });
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) /
        1000; // Convert to km
  }

  void _applyFilters() {
    String searchQuery = _searchController.text.toLowerCase();

    setState(() {
      _filteredCenters = _filteredCenters.where((center) {
        bool matchesSearch =
            center['name'].toLowerCase().contains(searchQuery) ||
                center['address'].toLowerCase().contains(searchQuery);

        bool matchesFilter = true;
        switch (_selectedFilter) {
          case 'Nearest':
            matchesFilter = true; // Already sorted by distance
            break;
          case 'Available Now':
            matchesFilter = center['status'] == 'Open';
            break;
          case 'Hospitals':
            matchesFilter = center['type'] == 'Hospital';
            break;
          case 'Blood Banks':
            matchesFilter = center['type'] == 'Blood Bank';
            break;
        }

        return matchesSearch && matchesFilter;
      }).toList();

      // Sort by distance if 'Nearest' is selected
      if (_selectedFilter == 'Nearest') {
        _filteredCenters.sort((a, b) =>
            double.parse(a['distance']).compareTo(double.parse(b['distance'])));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        title: const Text(
          'Donation Centers',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isListView ? Icons.map : Icons.list,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isListView = !_isListView;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildFilters(),
                Expanded(
                  child: _isListView ? _buildListView() : _buildMapView(),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search donation centers...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFFCC2B2B)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show advanced filters
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFCC2B2B).withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFCC2B2B) : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      isSelected ? const Color(0xFFCC2B2B) : Colors.grey[300]!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 13,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapToolbarEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: true,
      mapType: MapType.normal,
      onTap: (_) {
        // Close any open info windows when tapping the map
        setState(() {
          _markers = _markers.map((marker) {
            return marker.copyWith(
              infoWindowParam: InfoWindow(
                title: marker.infoWindow.title,
                snippet: marker.infoWindow.snippet,
              ),
            );
          }).toSet();
        });
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCenters.length,
      itemBuilder: (context, index) {
        final center = _filteredCenters[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
          child: InkWell(
            onTap: () => _showCenterDetails(center),
            borderRadius: BorderRadius.circular(15),
            child: Column(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      center['type'] == 'Hospital'
                          ? FontAwesomeIcons.hospitalUser
                          : FontAwesomeIcons.handHoldingMedical,
                      size: 40,
                      color: const Color(0xFFCC2B2B),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              center['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: center['status'] == 'Open'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              center['status'],
                              style: TextStyle(
                                color: center['status'] == 'Open'
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              center['address'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber[700]),
                          const SizedBox(width: 4),
                          Text(
                            '${center['rating']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' (${center['reviews']} reviews)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${center['distance']} km',
                            style: const TextStyle(
                              color: Color(0xFFCC2B2B),
                              fontWeight: FontWeight.bold,
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
      },
    );
  }

  void _showCenterDetails(Map<String, dynamic> center) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          center['type'] == 'Hospital'
                              ? FontAwesomeIcons.hospitalUser
                              : FontAwesomeIcons.handHoldingMedical,
                          size: 40,
                          color: const Color(0xFFCC2B2B),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              center['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    size: 16, color: Colors.amber[700]),
                                const SizedBox(width: 4),
                                Text(
                                  '${center['rating']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' (${center['reviews']} reviews)',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: center['status'] == 'Open'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                center['status'],
                                style: TextStyle(
                                  color: center['status'] == 'Open'
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    'Location & Contact',
                    [
                      _buildInfoRow(Icons.location_on, center['address']),
                      _buildInfoRow(Icons.phone, center['phone']),
                      _buildInfoRow(Icons.language, center['website']),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    'Hours & Availability',
                    [
                      _buildInfoRow(Icons.access_time, center['hours']),
                      _buildInfoRow(Icons.people,
                          'Current wait time: ${center['waitTime']}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    'Services',
                    [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            (center['services'] as List<String>).map((service) {
                          return Chip(
                            label: Text(service),
                            backgroundColor:
                                const Color(0xFFCC2B2B).withOpacity(0.1),
                            labelStyle: const TextStyle(
                              color: Color(0xFFCC2B2B),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    'Blood Types Needed',
                    [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            (center['bloodTypes'] as List<String>).map((type) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCC2B2B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(
                                color: Color(0xFFCC2B2B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to appointment booking
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC2B2B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Schedule Donation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFCC2B2B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
