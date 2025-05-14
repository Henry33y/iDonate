import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
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
    try {
      // Create user with email and password
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'phone': phone,
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'gender': gender,
        'bloodType': bloodType,
        'role': role,
        'location': location,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'healthNotes': healthNotes,
        'religion': religion,
        'isAnonymous': isAnonymous,
        'donationCount': 0,
        'livesSaved': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
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
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

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

      await _firestore.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}
