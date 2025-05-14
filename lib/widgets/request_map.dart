import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/blood_requests_provider.dart';

class RequestMap extends StatefulWidget {
  final List<BloodRequest> requests;

  const RequestMap({
    super.key,
    required this.requests,
  });

  @override
  State<RequestMap> createState() => _RequestMapState();
}

class _RequestMapState extends State<RequestMap> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _center;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    if (widget.requests.isEmpty) return;

    // Find the first request with a valid location
    final requestWithLocation = widget.requests.firstWhere(
      (request) => request.needLocation != null,
      orElse: () => widget.requests.first,
    );

    if (requestWithLocation.needLocation != null) {
      _center = LatLng(
        requestWithLocation.needLocation!['lat'] ?? 0.0,
        requestWithLocation.needLocation!['lng'] ?? 0.0,
      );
    } else {
      // Default to a central location if no location data is available
      _center = const LatLng(0.0, 0.0);
    }

    _updateMarkers();
  }

  void _updateMarkers() {
    _markers.clear();
    for (final request in widget.requests) {
      if (request.needLocation != null) {
        final position = LatLng(
          request.needLocation!['lat'] ?? 0.0,
          request.needLocation!['lng'] ?? 0.0,
        );

        _markers.add(
          Marker(
            markerId: MarkerId(request.id),
            position: position,
            infoWindow: InfoWindow(
              title: request.userName,
              snippet:
                  '${request.bloodGroup} - ${request.urgencyLevel.toString().split('.').last}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_center == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _center!,
        zoom: 12,
      ),
      markers: _markers,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
 