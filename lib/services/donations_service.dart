import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get donations => _firestore.collection('donations');
  CollectionReference get users => _firestore.collection('users');

  // Create a new donation
  Future<void> createDonation({
    required String type,
    required String description,
    required String location,
    required DateTime date,
    required String status,
    String? bloodType,
    String? gender,
    int? age,
    double? weight,
    DateTime? lastDonationDate,
    bool? hasRecentSurgery,
    bool? hasChronicDisease,
    bool? isPregnant,
    bool? hasTattoo,
    DateTime? lastMealTime,
  }) async {
    print('Creating donation...');
    final user = auth.currentUser;
    if (user == null) {
      print('Error: User not authenticated');
      throw Exception('User not authenticated');
    }
    print('Current user: ${user.uid}');

    final donationData = {
      'userId': user.uid,
      'type': type,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'status': status,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'bloodType': bloodType,
      'gender': gender,
      'age': age,
      'weight': weight,
      'lastDonationDate': lastDonationDate != null
          ? Timestamp.fromDate(lastDonationDate)
          : null,
      'hasRecentSurgery': hasRecentSurgery,
      'hasChronicDisease': hasChronicDisease,
      'isPregnant': isPregnant,
      'hasTattoo': hasTattoo,
      'lastMealTime':
          lastMealTime != null ? Timestamp.fromDate(lastMealTime) : null,
    };

    print('Donation data: $donationData');

    try {
      final docRef = await donations.add(donationData);
      print('Donation created successfully with ID: ${docRef.id}');

      // Update user's donation count
      await users.doc(user.uid).update({
        'donationCount': FieldValue.increment(1),
        'livesSaved':
            FieldValue.increment(3), // Assuming each donation saves 3 lives
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User donation count updated successfully');
    } catch (e) {
      print('Error creating donation: $e');
      rethrow;
    }
  }

  // Get all donations
  Stream<QuerySnapshot> getAllDonations() {
    print('Getting all donations...');
    return donations.orderBy('date', descending: true).snapshots();
  }

  // Get donations by user
  Stream<QuerySnapshot> getUserDonations(String userId) {
    print('Getting donations for user: $userId');
    return donations
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Update donation status
  Future<void> updateDonationStatus(String donationId, String newStatus) async {
    print('Updating donation status: $donationId to $newStatus');
    try {
      await donations.doc(donationId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Donation status updated successfully');
    } catch (e) {
      print('Error updating donation status: $e');
      rethrow;
    }
  }

  // Delete donation
  Future<void> deleteDonation(String donationId) async {
    print('Deleting donation: $donationId');
    try {
      await donations.doc(donationId).delete();
      print('Donation deleted successfully');
    } catch (e) {
      print('Error deleting donation: $e');
      rethrow;
    }
  }

  // Get donation by ID
  Future<DocumentSnapshot> getDonationById(String donationId) async {
    print('Getting donation by ID: $donationId');
    try {
      final doc = await donations.doc(donationId).get();
      print('Donation retrieved: ${doc.exists ? 'exists' : 'does not exist'}');
      return doc;
    } catch (e) {
      print('Error getting donation: $e');
      rethrow;
    }
  }

  // Count and update user's donations
  Future<void> updateUserDonationCount(String userId) async {
    print('Updating donation count for user: $userId');
    try {
      // Get all donations for the user
      final querySnapshot = await donations
          .where('userId', isEqualTo: userId)
          .get();

      // Count the donations
      final donationCount = querySnapshot.docs.length;
      final livesSaved = donationCount * 3; // Assuming each donation saves 3 lives

      // Update user document with the correct count
      await users.doc(userId).update({
        'donationCount': donationCount,
        'livesSaved': livesSaved,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User donation count updated to: $donationCount');
    } catch (e) {
      print('Error updating user donation count: $e');
      rethrow;
    }
  }
}
