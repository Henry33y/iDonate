import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart'; // Import to manage system UI overlays

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDarkMode = false; // Track dark mode state

  @override
  void initState() {
    super.initState();
    // Set the status bar to transparent to match the red section
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar transparent
      statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark, // Adjust the icon brightness for dark mode
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Make the AppBar transparent
          elevation: 0, // Remove the shadow of the AppBar
          automaticallyImplyLeading: false, // Remove the leading (back) icon
        ),
        extendBodyBehindAppBar: true, // Allow body to extend behind the AppBar
        drawer: Drawer(
          backgroundColor: _isDarkMode ? Colors.grey[850] : Colors.white, // Drawer color based on theme
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.red),
                child: Text(
                  'iDonate Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              drawerItem(Icons.home, "Home"),
              drawerItem(Icons.history, "History"),
              drawerItem(Icons.bloodtype, "Blood Compatibility Chart"),
              drawerItem(Icons.local_hospital, "Hospitals & Donation Centres"),
              drawerItem(Icons.message, "Messages"),
              drawerItem(Icons.people, "Donors"),
              drawerItem(Icons.settings, "Settings"),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          currentIndex: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "Requests"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Donations"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
        body: SafeArea(
          top: false, // Remove top padding to avoid extra white space
          child: Column(
            children: [
              // Top red section with more oval shape
              Container(
                width: double.infinity,
                height: screenHeight * 0.45,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(80)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: Icon(Icons.menu, color: Colors.white),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        const Text(
                          "iDonate",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        // Dark/Light mode toggle (crescent/sun)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDarkMode = !_isDarkMode;
                            });
                            // Update status bar icon brightness based on mode
                            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                              statusBarColor: Colors.transparent,
                              statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
                            ));
                          },
                          child: _isDarkMode
                              ? Icon(
                                  FontAwesomeIcons.moon,
                                  color: Colors.white,
                                  size: 30,
                                ) // Crescent moon for dark mode
                              : Icon(
                                  Icons.wb_sunny,
                                  color: Colors.white,
                                  size: 30,
                                ), // Sun icon for light mode
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: screenHeight * 0.28,
                      child: Center(
                        child: Image.asset(
                          'assets/images/blood.png',
                          fit: BoxFit.contain,
                          width: screenWidth * 0.9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Space to push buttons down
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 40),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      featureCard(Icons.add_circle, "Donate"),
                      featureCard(Icons.navigation, "Request"),
                      featureCard(Icons.location_pin, "Donation Centres"),
                      featureCard(Icons.bloodtype, "Blood Compatibility\nChart"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Drawer item builder
  Widget drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        // TODO: Add navigation logic here
      },
    );
  }

  Widget featureCard(IconData icon, String label) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
