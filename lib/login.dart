import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'HomePage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '655086831488-5kqeg9he2a1pfuni6q7ufh29ndvlmv2v.apps.googleusercontent.com'
        : null,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );
  bool _isLoading = false;

  String _getErrorMessage(dynamic error) {
    print('Error details: $error'); // Add detailed error logging
    if (error is FirebaseAuthException) {
      print('Firebase error code: ${error.code}'); // Log Firebase error code
      switch (error.code) {
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address but different sign-in credentials.';
        case 'invalid-credential':
          return 'The credential received is malformed or has expired.';
        case 'operation-not-allowed':
          return 'Google Sign-In is not enabled. Please contact support.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-verification-code':
          return 'The verification code is invalid.';
        case 'invalid-verification-id':
          return 'The verification ID is invalid.';
        case 'network-request-failed':
          return 'A network error occurred. Please check your internet connection.';
        default:
          return 'An error occurred during sign in: ${error.message}';
      }
    } else if (error.toString().contains('network_error')) {
      return 'A network error occurred. Please check your internet connection.';
    } else if (error.toString().contains('sign_in_canceled')) {
      return 'Sign in was canceled by the user.';
    } else if (error.toString().contains('sign_in_failed')) {
      return 'Sign in failed. Please try again.';
    }
    return 'An unexpected error occurred: $error';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Check if user is already signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('Google user: $googleUser'); // Log Google user

      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
          'Google auth token: ${googleAuth.idToken != null}'); // Log token status

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print('Firebase user: ${userCredential.user?.uid}'); // Log Firebase user

      setState(() {
        _isLoading = false;
      });

      return userCredential;
    } catch (e) {
      print('Sign in error: $e'); // Log the full error
      setState(() {
        _isLoading = false;
      });

      String errorMessage = _getErrorMessage(e);
      _showErrorDialog(errorMessage);

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.17),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Colors.red,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    "Click to sign in with Google",
                    style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.black54,
                        fontFamily: 'Montserrat'),
                  ),
                ),
                SizedBox(height: screenHeight * 0.10),
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.red)
                      : ElevatedButton.icon(
                          onPressed: () async {
                            final userCredential = await _signInWithGoogle();
                            if (userCredential != null && mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()),
                              );
                            }
                          },
                          icon: const FaIcon(FontAwesomeIcons.google,
                              color: Colors.white, size: 20),
                          label: Text(
                            "Log in",
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.30,
                              vertical: screenHeight * 0.03,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                ),
                Expanded(child: Container()),
                Center(
                  child: Text(
                    "iDonate",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          );
        },
      ),
    );
  }
}
