import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum UrgencyLevel { low, medium, high, critical }

class Request {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final UrgencyLevel urgency;
  final DateTime createdAt;
  final bool isFulfilled;
  final String? fulfilledBy;
  final DateTime? fulfilledAt;
  final String bloodType;
  final LatLng location;

  Request({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.urgency,
    required this.createdAt,
    this.isFulfilled = false,
    this.fulfilledBy,
    this.fulfilledAt,
    required this.bloodType,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'urgency': urgency.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'isFulfilled': isFulfilled,
      'fulfilledBy': fulfilledBy,
      'fulfilledAt':
          fulfilledAt != null ? Timestamp.fromDate(fulfilledAt!) : null,
      'bloodType': bloodType,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    };
  }

  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      urgency: UrgencyLevel.values.firstWhere(
        (e) => e.toString().split('.').last == map['urgency'],
        orElse: () => UrgencyLevel.medium,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isFulfilled: map['isFulfilled'] ?? false,
      fulfilledBy: map['fulfilledBy'],
      fulfilledAt: map['fulfilledAt'] != null
          ? (map['fulfilledAt'] as Timestamp).toDate()
          : null,
      bloodType: map['bloodType'] ?? '',
      location: LatLng(
        map['location']?['latitude'] ?? 0.0,
        map['location']?['longitude'] ?? 0.0,
      ),
    );
  }
}
