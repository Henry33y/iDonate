import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/request.dart';

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

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

      if (request.urgency == UrgencyLevel.critical) {
        await _sendCriticalRequestNotification(request);
      }
    } catch (e) {
      print('Exception in createRequest: $e');
      throw Exception('Failed to create request: $e');
    }
  }

  Future<void> _sendCriticalRequestNotification(Request request) async {
    try {
      // Get all user FCM tokens
      final usersSnapshot = await _firestore.collection('users').get();
      final tokens = usersSnapshot.docs
          .map((doc) => doc.data()['fcmToken'] as String?)
          .where((token) => token != null)
          .toList();

      // Send notification to all users
      for (final token in tokens) {
        if (token != null) {
          await _messaging.sendToTopic(
            'critical_requests',
            notification: RemoteNotification(
              title: 'Critical Request Alert!',
              body: '${request.title} - Urgent help needed!',
            ),
            data: {
              'requestId': request.id,
              'type': 'critical_request',
            },
          );
        }
      }
    } catch (e) {
      print('Error sending critical request notification: $e');
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
