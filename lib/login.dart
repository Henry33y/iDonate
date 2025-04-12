import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'HomePage.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08), // Responsive padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left-aligned "Welcome" text
                SizedBox(height: screenHeight * 0.17),
                SizedBox(
                  width: double.infinity, // Ensures left alignment
                  child: Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: screenWidth * 0.06, // Scales with screen
                      fontWeight: FontWeight.bold, fontFamily: 'Montserrat',
                      color: Colors.red,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                // Left-aligned "Click to sign in with Google"
                SizedBox(
                  width: double.infinity, // Ensures left alignment
                  child: Text(
                    "Click to sign in with Google",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.black54, fontFamily: 'Montserrat'
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.10),

                // Centered Google Login Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                    icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white, size: 20),
                    label: Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // Scales with screen
                        fontFamily: 'Montserrat',
                        color: Colors.white, fontWeight:FontWeight.bold
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.30, // ✅ Responsive button width
                        vertical: screenHeight * 0.03, // ✅ Responsive button height
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                Expanded(child: Container()), // Pushes the bottom text down

                // Centered "iDonate" text
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
