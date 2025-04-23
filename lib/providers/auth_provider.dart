import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:html' as html;
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _firebaseService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (html.window.navigator.userAgent.contains('Firefox')) {
        // For Firefox, use the standard sign-in flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _firebaseService.signInWithCredential(credential);
      } else {
        // For other browsers, use the recommended web approach
        final provider = GoogleAuthProvider();
        provider.addScope('https://www.googleapis.com/auth/userinfo.email');
        provider.addScope('https://www.googleapis.com/auth/userinfo.profile');

        await _firebaseService.signInWithPopup(provider);
      }

      // Create user document if it doesn't exist
      await _firebaseService.createUserDocument();
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firebaseService.signOut();
      _user = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUserDocument() async {
    if (_user != null) {
      final exists = await _firebaseService.userDocumentExists(_user!.uid);
      if (!exists) {
        await _firebaseService.createUserDocument(_user);
      }
    }
  }
}
