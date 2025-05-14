import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  User? get currentUser => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required DateTime dateOfBirth,
    required String gender,
    required String bloodType,
    required String role,
    required String location,
    required String emergencyContactName,
    required String emergencyContactPhone,
    String? healthNotes,
    String? religion,
    required bool isAnonymous,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        bloodType: bloodType,
        role: role,
        location: location,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        healthNotes: healthNotes,
        religion: religion,
        isAnonymous: isAnonymous,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signIn(
        email: email,
        password: password,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
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
      await _authService.updateProfile(
        name: name,
        phone: phone,
        location: location,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        healthNotes: healthNotes,
        religion: religion,
        isAnonymous: isAnonymous,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    notifyListeners();
  }
}
