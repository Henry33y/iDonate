import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UsersProvider with ChangeNotifier {
  final UserService _userService = UserService();
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
}
