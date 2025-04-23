import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/donations_service.dart';

class DonationsProvider with ChangeNotifier {
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
    _donationsService.getAllDonations().listen((snapshot) {
      _donations = snapshot.docs;
      notifyListeners();
    });
  }

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
    _isLoading = true;
    notifyListeners();

    try {
      await _donationsService.createDonation(
        type: type,
        description: description,
        location: location,
        date: date,
        status: status,
        bloodType: bloodType,
        gender: gender,
        age: age,
        weight: weight,
        lastDonationDate: lastDonationDate,
        hasRecentSurgery: hasRecentSurgery,
        hasChronicDisease: hasChronicDisease,
        isPregnant: isPregnant,
        hasTattoo: hasTattoo,
        lastMealTime: lastMealTime,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update donation status
  Future<void> updateDonationStatus(String donationId, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _donationsService.updateDonationStatus(donationId, newStatus);
    } catch (e) {
      print('Error updating donation status: $e');
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
      await _donationsService.deleteDonation(donationId);
    } catch (e) {
      print('Error deleting donation: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
