import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/donations_service.dart';

class DonationsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DonationsService _donationsService = DonationsService();
  bool _isLoading = false;
  List<DocumentSnapshot> _donations = [];

  bool get isLoading => _isLoading;
  List<DocumentSnapshot> get donations => _donations;

  // Initialize the provider
  DonationsProvider() {
    _init();
  }

  Future<void> _init() async {
    final user = _donationsService.auth.currentUser;
    if (user != null) {
      try {
        // Update donation count first
        await _donationsService.updateUserDonationCount(user.uid);

        // Try to get donations with sorting first
        try {
          _donationsService.getUserDonations(user.uid).listen((snapshot) {
            _donations = snapshot.docs;
            notifyListeners();
          });
        } catch (e) {
          // If the sorted query fails, fall back to unsorted query
          debugPrint('Falling back to unsorted query: $e');
          _firestore
              .collection('donations')
              .where('userId', isEqualTo: user.uid)
              .snapshots()
              .listen((snapshot) {
            _donations = snapshot.docs;
            notifyListeners();
          });
        }
      } catch (e) {
        debugPrint('Error in _init: $e');
      }
    }
  }

  // Create a new donation
  Future<void> createDonation({
    required String donorId,
    required String recipientId,
    required String bloodType,
    required DateTime date,
    required String location,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Create the donation document
      final donationRef = await _firestore.collection('donations').add({
        'userId': donorId,
        'recipientId': recipientId,
        'bloodType': bloodType,
        'date': Timestamp.fromDate(date),
        'location': location,
        'notes': notes,
        'status': 'scheduled',
        'type': 'blood',
        'description': notes ?? 'Blood donation appointment',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update donor's donation count
      await _firestore.collection('users').doc(donorId).update({
        'donationCount': FieldValue.increment(1),
        'livesSaved': FieldValue.increment(3),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating donation: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update donation status
  Future<void> updateDonationStatus(String donationId, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('donations').doc(donationId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating donation status: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete donation
  Future<void> deleteDonation(String donationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('donations').doc(donationId).delete();
    } catch (e) {
      debugPrint('Error deleting donation: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<QuerySnapshot> getDonationsForUser(String userId) {
    try {
      // Try the sorted query first
      return _firestore
          .collection('donations')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots();
    } catch (e) {
      // If the sorted query fails, fall back to unsorted query
      debugPrint('Falling back to unsorted query: $e');
      return _firestore
          .collection('donations')
          .where('userId', isEqualTo: userId)
          .snapshots();
    }
  }

  Stream<QuerySnapshot> getDonationsForRecipient(String userId) {
    try {
      // Try the sorted query first
      return _firestore
          .collection('donations')
          .where('recipientId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots();
    } catch (e) {
      // If the sorted query fails, fall back to unsorted query
      debugPrint('Falling back to unsorted query: $e');
      return _firestore
          .collection('donations')
          .where('recipientId', isEqualTo: userId)
          .snapshots();
    }
  }
}
