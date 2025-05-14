import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/request.dart';
import 'notification_service.dart';

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<void> createRequest(Request request) async {
    try {
      print('Creating request with ID: ${request.id}');
      print('Request data: ${request.toMap()}');

      await _firestore
          .collection('requests')
          .doc(request.id)
          .set(request.toMap())
          .then((_) => print('Request created successfully'))
          .catchError((error) => print('Error creating request: $error'));

      // Send notifications to nearby users and institutions
      await _notificationService.sendBloodRequestNotification(
        requestId: request.id,
        bloodType: request.bloodType,
        requestLat: request.location.latitude,
        requestLon: request.location.longitude,
        radiusInMeters: 50000, // 50km radius
      );
    } catch (e) {
      print('Exception in createRequest: $e');
      throw Exception('Failed to create request: $e');
    }
  }

  Stream<List<Request>> getRequests() {
    return _firestore
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Request.fromMap(doc.data())).toList());
  }

  Future<void> updateRequestStatus(String requestId, String fulfilledBy) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'isFulfilled': true,
        'fulfilledBy': fulfilledBy,
        'fulfilledAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }
}
