import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  CollectionReference get users => _firestore.collection('users');

  // Get all eligible donors
  Stream<List<User>> getEligibleDonors() {
    return users.where('isEligible', isEqualTo: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => User.fromFirestore(doc)).toList());
  }

  // Update user eligibility based on their information
  Future<void> updateUserEligibility(String userId) async {
    final userDoc = await users.doc(userId).get();
    final data = userDoc.data() as Map<String, dynamic>;

    // Check eligibility criteria
    final age = data['age'] as int?;
    final weight = data['weight'] as double?;
    final hasRecentSurgery = data['hasRecentSurgery'] as bool?;
    final hasChronicDisease = data['hasChronicDisease'] as bool?;
    final isPregnant = data['isPregnant'] as bool?;
    final hasTattoo = data['hasTattoo'] as bool?;
    final lastDonationDate = data['lastDonationDate'] as Timestamp?;

    bool isEligible = true;

    // Age check (18-65)
    if (age == null || age < 18 || age > 65) {
      isEligible = false;
    }

    // Weight check (minimum 50kg)
    if (weight == null || weight < 50) {
      isEligible = false;
    }

    // Health checks
    if (hasRecentSurgery == true ||
        hasChronicDisease == true ||
        isPregnant == true ||
        hasTattoo == true) {
      isEligible = false;
    }

    // Last donation check (minimum 56 days between donations)
    if (lastDonationDate != null) {
      final daysSinceLastDonation =
          DateTime.now().difference(lastDonationDate.toDate()).inDays;
      if (daysSinceLastDonation < 56) {
        isEligible = false;
      }
    }

    // Calculate achievements
    final donationCount = data['donationCount'] as int? ?? 0;
    final livesSaved = data['livesSaved'] as int? ?? 0;
    final isHospitalVerified = data['isHospitalVerified'] as bool? ?? false;

    final achievements = <String>[];
    if (donationCount >= 1) achievements.add('First Donation');
    if (donationCount >= 5) achievements.add('Regular Donor');
    if (livesSaved >= 10) achievements.add('Life Saver');
    if (isHospitalVerified) achievements.add('Hospital Verified');

    // Update user document
    await users.doc(userId).update({
      'isEligible': isEligible,
      'achievements': achievements,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Create or update user document
  Future<void> createOrUpdateUser({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
    String? bloodType,
    String? gender,
    int? age,
    double? weight,
    DateTime? lastDonationDate,
    bool? hasRecentSurgery,
    bool? hasChronicDisease,
    bool? isPregnant,
    bool? hasTattoo,
    int? donationCount,
    int? livesSaved,
    bool? isHospitalVerified,
    String? verifiedBy,
    DateTime? verificationDate,
  }) async {
    final userDoc = await users.doc(userId).get();
    final anonymizedUsername = 'Donor#${userId.substring(0, 4)}';

    // Calculate achievements based on current data
    final currentData =
        userDoc.exists ? userDoc.data() as Map<String, dynamic> : {};
    final currentDonationCount =
        donationCount ?? currentData['donationCount'] as int? ?? 0;
    final currentLivesSaved =
        livesSaved ?? currentData['livesSaved'] as int? ?? 0;
    final currentHospitalVerified = isHospitalVerified ??
        currentData['isHospitalVerified'] as bool? ??
        false;

    final achievements = <String>[];
    if (currentDonationCount >= 1) achievements.add('First Donation');
    if (currentDonationCount >= 5) achievements.add('Regular Donor');
    if (currentLivesSaved >= 10) achievements.add('Life Saver');
    if (currentHospitalVerified) achievements.add('Hospital Verified');

    if (!userDoc.exists) {
      // Create new user document
      await users.doc(userId).set({
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
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
        'isEligible': false,
        'anonymizedUsername': anonymizedUsername,
        'donationCount': currentDonationCount,
        'livesSaved': currentLivesSaved,
        'achievements': achievements,
        'isHospitalVerified': currentHospitalVerified,
        'verifiedBy': verifiedBy,
        'verificationDate': verificationDate != null
            ? Timestamp.fromDate(verificationDate)
            : null,
        'verificationLevel': 'Not Verified',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing user document
      await users.doc(userId).update({
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
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
        'anonymizedUsername': anonymizedUsername,
        'donationCount': currentDonationCount,
        'livesSaved': currentLivesSaved,
        'achievements': achievements,
        'isHospitalVerified': currentHospitalVerified,
        'verifiedBy': verifiedBy,
        'verificationDate': verificationDate != null
            ? Timestamp.fromDate(verificationDate)
            : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // Update eligibility after creating/updating user
    await updateUserEligibility(userId);
  }

  // Update donation count and lives saved
  Future<void> updateDonationStats(String userId,
      {int? donationCount, int? livesSaved}) async {
    await users.doc(userId).update({
      'donationCount': FieldValue.increment(donationCount ?? 0),
      'livesSaved': FieldValue.increment(livesSaved ?? 0),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await updateUserEligibility(userId);
  }

  // Update hospital verification status
  Future<void> updateHospitalVerification(
    String userId, {
    required bool isVerified,
    required String verifiedBy,
  }) async {
    await users.doc(userId).update({
      'isHospitalVerified': isVerified,
      'verifiedBy': verifiedBy,
      'verificationDate': FieldValue.serverTimestamp(),
      'verificationLevel': isVerified ? 'Hospital Verified' : 'Not Verified',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await updateUserEligibility(userId);
  }
}
