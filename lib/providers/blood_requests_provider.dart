import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestUrgency {
  critical,
  urgent,
  standard,
}

enum RequestStatus {
  open,
  pending,
  booked,
  fulfilled,
  cancelled,
}

class BloodRequest {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String bloodGroup;
  final String genotype;
  final RequestUrgency urgencyLevel;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? needLocation;
  final Map<String, dynamic>? donationCentre;
  final int unitsNeeded;
  final Map<String, dynamic>? preferredDonorSettings;
  final bool isActive;
  final String? acceptedBy;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;

  BloodRequest({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.bloodGroup,
    required this.genotype,
    required this.urgencyLevel,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.needLocation,
    this.donationCentre,
    required this.unitsNeeded,
    this.preferredDonorSettings,
    required this.isActive,
    this.acceptedBy,
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
  });

  factory BloodRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BloodRequest(
      id: doc.id,
      userId: data['requesterId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      bloodGroup: data['bloodType'] ?? '',
      genotype: data['genotype'] ?? '',
      urgencyLevel: _parseUrgencyLevel(data['urgency']),
      status: _parseStatus(data['status']),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      needLocation: data['needLocation'],
      donationCentre: data['donationCentre'],
      unitsNeeded: data['unitsNeeded'] ?? 1,
      preferredDonorSettings: data['preferredDonorSettings'],
      isActive: data['status'] == 'open',
      acceptedBy: data['acceptedBy'],
      acceptedAt: data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      cancelledAt: data['cancelledAt'] != null
          ? (data['cancelledAt'] as Timestamp).toDate()
          : null,
      cancelledBy: data['cancelledBy'],
      cancellationReason: data['cancellationReason'],
    );
  }

  static RequestUrgency _parseUrgencyLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'critical':
        return RequestUrgency.critical;
      case 'urgent':
        return RequestUrgency.urgent;
      case 'standard':
        return RequestUrgency.standard;
      default:
        return RequestUrgency.standard;
    }
  }

  static RequestStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return RequestStatus.open;
      case 'pending':
        return RequestStatus.pending;
      case 'booked':
        return RequestStatus.booked;
      case 'fulfilled':
        return RequestStatus.fulfilled;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.open;
    }
  }
}

class BloodRequestsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<BloodRequest> _requests = [];

  bool get isLoading => _isLoading;
  List<BloodRequest> get requests => _requests;

  // Initialize the provider
  BloodRequestsProvider() {
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      _isLoading = true;
      notifyListeners();

      _firestore
          .collection('requests')
          .where('status', isEqualTo: 'open')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        _requests = snapshot.docs
            .map((doc) => BloodRequest.fromFirestore(doc))
            .toList();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error loading requests: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> respondToRequest(String requestId, String donorId) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'acceptedBy': donorId,
        'acceptedAt': FieldValue.serverTimestamp(),
        'status': 'fulfilled',
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error responding to request: $e');
      rethrow;
    }
  }

  Future<void> cancelRequest(String requestId, String reason) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': 'cancelled',
        'isActive': false,
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancellationReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error cancelling request: $e');
      rethrow;
    }
  }
}
 