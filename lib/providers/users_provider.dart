import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<User> _eligibleDonors = [];

  bool get isLoading => _isLoading;
  List<User> get eligibleDonors => _eligibleDonors;

  UsersProvider() {
    _loadEligibleDonors();
  }

  void _loadEligibleDonors() {
    _userService.getEligibleDonors().listen((donors) {
      _eligibleDonors = donors;
      notifyListeners();
    });
  }

  Future<void> updateUserEligibility(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _userService.updateUserEligibility(userId);
    } catch (e) {
      debugPrint('Error updating user eligibility: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    try {
      _isLoading = true;
      notifyListeners();
      await _userService.createOrUpdateUser(
        userId: userId,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        bloodType: bloodType,
        gender: gender,
        age: age,
        weight: weight,
        lastDonationDate: lastDonationDate,
        hasRecentSurgery: hasRecentSurgery,
        hasChronicDisease: hasChronicDisease,
        isPregnant: isPregnant,
        hasTattoo: hasTattoo,
        donationCount: donationCount,
        livesSaved: livesSaved,
        isHospitalVerified: isHospitalVerified,
        verifiedBy: verifiedBy,
        verificationDate: verificationDate,
      );
    } catch (e) {
      debugPrint('Error creating/updating user: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDonationStats(String userId,
      {int? donationCount, int? livesSaved}) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _userService.updateDonationStats(userId,
          donationCount: donationCount, livesSaved: livesSaved);
    } catch (e) {
      debugPrint('Error updating donation stats: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHospitalVerification(
    String userId, {
    required bool isVerified,
    required String verifiedBy,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _userService.updateHospitalVerification(
        userId,
        isVerified: isVerified,
        verifiedBy: verifiedBy,
      );
    } catch (e) {
      debugPrint('Error updating hospital verification: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<DocumentSnapshot> getUserData(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? location,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? healthNotes,
    String? religion,
    bool? isAnonymous,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (location != null) updateData['location'] = location;
      if (emergencyContactName != null)
        updateData['emergencyContactName'] = emergencyContactName;
      if (emergencyContactPhone != null)
        updateData['emergencyContactPhone'] = emergencyContactPhone;
      if (healthNotes != null) updateData['healthNotes'] = healthNotes;
      if (religion != null) updateData['religion'] = religion;
      if (isAnonymous != null) updateData['isAnonymous'] = isAnonymous;

      await _firestore.collection('users').doc(userId).update(updateData);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<QuerySnapshot> searchUsers({
    String? bloodType,
    String? location,
    bool? isAnonymous,
  }) {
    Query query = _firestore.collection('users');

    if (bloodType != null) {
      query = query.where('bloodType', isEqualTo: bloodType);
    }

    if (location != null) {
      query = query.where('location', isEqualTo: location);
    }

    if (isAnonymous != null) {
      query = query.where('isAnonymous', isEqualTo: isAnonymous);
    }

    return query.snapshots();
  }
}
