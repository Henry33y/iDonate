import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _serverUrl = 'http://192.168.93.140:3000/api'; // For Android emulator

  // Initialize notification settings
  Future<void> initialize() async {
    try {
      print('Initializing notification service...');

      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('Notification permission status: ${settings.authorizationStatus}');

      // Get FCM token
      String? token = await _messaging.getToken();
      print('FCM Token: $token');

      if (token != null) {
        // Store the token in Firestore for the current user
        await _storeFcmToken(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        _storeFcmToken(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification?.title}');

        // You can show a local notification here if needed
      });

      // Handle notification click when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Message clicked!');
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification?.title}');
      });
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  // Store FCM token in Firestore
  Future<void> _storeFcmToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in, cannot store FCM token');
        return;
      }

      print('Storing FCM token for user: ${user.uid}');

      // First check if the user document exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        print('User document does not exist, creating it...');
        await _firestore.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
          'email': user.email,
        });
      } else {
        print('Updating existing user document with new FCM token');
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('Successfully stored FCM token');
    } catch (e) {
      print('Error storing FCM token: $e');
    }
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Send notification to nearby users and institutions
  Future<void> sendBloodRequestNotification({
    required String requestId,
    required String bloodType,
    required double requestLat,
    required double requestLon,
    required double radiusInMeters,
  }) async {
    try {
      // Get all users and institutions
      final usersSnapshot = await _firestore.collection('users').get();
      final institutionsSnapshot =
          await _firestore.collection('institutions').get();

      // Combine users and institutions
      final allRecipients = [
        ...usersSnapshot.docs,
        ...institutionsSnapshot.docs
      ];

      // Filter recipients based on distance and blood type
      final nearbyRecipients = allRecipients.where((doc) {
        final data = doc.data();
        final recipientLat = data['latitude'] as double?;
        final recipientLon = data['longitude'] as double?;
        final recipientBloodType = data['bloodType'] as String?;

        if (recipientLat == null || recipientLon == null) return false;

        // Calculate distance
        final distance = _calculateDistance(
          requestLat,
          requestLon,
          recipientLat,
          recipientLon,
        );

        // Check if recipient is within radius and has matching blood type
        return distance <= radiusInMeters &&
            (recipientBloodType == bloodType || recipientBloodType == 'O-');
      }).toList();

      // Get request details
      final requestDoc =
          await _firestore.collection('requests').doc(requestId).get();
      final requestData = requestDoc.data();
      if (requestData == null) return;

      // Send notifications to nearby recipients
      for (var recipient in nearbyRecipients) {
        final fcmToken = recipient.data()['fcmToken'] as String?;
        if (fcmToken == null) continue;

        // Create notification in Firestore
        await _firestore.collection('notifications').add({
          'userId': recipient.id,
          'requestId': requestId,
          'title': 'New Blood Request Nearby',
          'body': '${requestData['title']} - ${requestData['description']}',
          'type': 'blood_request',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Send FCM notification through our backend server
        await _sendFcmNotification(
          token: fcmToken,
          title: 'New Blood Request Nearby',
          body: '${requestData['title']} - ${requestData['description']}',
          data: {
            'requestId': requestId,
            'type': 'blood_request',
          },
        );
      }
    } catch (e) {
      print('Error sending blood request notification: $e');
    }
  }

  // Send FCM notification through our backend server
  Future<void> _sendFcmNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      print('Sending FCM notification to token: ${token.substring(0, 10)}...');
      print('Title: $title');
      print('Body: $body');
      print('Data: $data');

      final response = await http.post(
        Uri.parse('$_serverUrl/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'title': title,
          'body': body,
          'data': data,
        }),
      );

      print('Server response status: ${response.statusCode}');
      print('Server response body: ${response.body}');

      if (response.statusCode != 200) {
        print('Error sending FCM message: ${response.body}');
        throw Exception('Failed to send FCM message: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM notification: $e');
      rethrow;
    }
  }
}
