import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get auth instance
  FirebaseAuth get auth => _auth;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with popup
  Future<UserCredential> signInWithPopup(GoogleAuthProvider provider) async {
    return await _auth.signInWithPopup(provider);
  }

  // Sign in with credential
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  // Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Create new user document in Firestore
  Future<void> createUserDocument([User? user]) async {
    final currentUser = user ?? _auth.currentUser;
    if (currentUser == null) return;

    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    if (!userDoc.exists) {
      await _firestore.collection('users').doc(currentUser.uid).set({
        'email': currentUser.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isEligible': false,
        'anonymizedUsername': 'Donor#${currentUser.uid.substring(0, 4)}',
      });
    }
  }

  // Check if user document exists
  Future<bool> userDocumentExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<void> initialize() async {
    await Firebase.initializeApp();
  }
}
