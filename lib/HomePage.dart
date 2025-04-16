import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart'; // Import to manage system UI overlays
import 'pages/appointments_page.dart';
import 'pages/messages_page.dart';
import 'pages/profile_page.dart';
import 'pages/notifications_page.dart';
import 'pages/history_page.dart';
import 'pages/compatibility_chart_page.dart';
import 'pages/request_blood_page.dart';
import 'pages/donate_page.dart';
import 'pages/active_requests_page.dart';
import 'pages/donors_page.dart';
import 'pages/settings_page.dart';
import 'pages/donation_centers_page.dart';

// Create a class to manage theme state
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final ThemeProvider _themeProvider = ThemeProvider();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _pages = [
    const HomeContent(),
    const AppointmentsPage(),
    const MessagesPage(),
    const ProfilePage(),
  ];

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Set the status bar to transparent to match the red section
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Listen to theme changes
    _themeProvider.addListener(() {
      setState(() {});
      if (_themeProvider.isDarkMode) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _themeProvider.isDarkMode 
        ? ThemeData.dark().copyWith(
            primaryColor: const Color(0xFFCC2B2B),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFCC2B2B),
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: const Color(0xFFCC2B2B),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFCC2B2B),
            ),
          ),
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _pages[_currentIndex],
        ),
        floatingActionButton: Container(
          height: 64,
          width: 64,
          margin: const EdgeInsets.only(top: 32),
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFCC2B2B),
            elevation: 8,
            child: const Icon(
              Icons.location_on,
              size: 32,
              color: Colors.white,
            ),
            onPressed: () {
              // Show a snackbar indicating feature coming soon
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Donor location feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side icons
                Row(
                  children: [
                    _buildNavItem(0, Icons.home, 'Home'),
                    const SizedBox(width: 32),
                    _buildNavItem(1, Icons.calendar_today, 'Appointments'),
                  ],
                ),
                // Right side icons
                Row(
                  children: [
                    _buildNavItem(2, Icons.message, 'Messages'),
                    const SizedBox(width: 32),
                    _buildNavItem(3, Icons.person, 'Profile'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _changePage(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFCC2B2B) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFCC2B2B) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Separate widget for home content
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final homeState = context.findAncestorStateOfType<_HomePageState>();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Row(
          children: [
            Icon(FontAwesomeIcons.droplet, size: 24),
            SizedBox(width: 10),
            Text(
              'iDonate',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
                key: ValueKey<bool>(isDarkMode),
              ),
            ),
            onPressed: () {
              final homeState = context.findAncestorStateOfType<_HomePageState>();
              if (homeState != null) {
                homeState._themeProvider.toggleTheme();
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode 
                ? [const Color(0xFF1F1F1F), const Color(0xFF121212)]
                : [Colors.white, const Color(0xFFF5F5F5)],
            ),
          ),
          child: Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFCC2B2B),
                      Color(0xFFE53935),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.droplet,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'iDonate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildDrawerItem(context, Icons.history, 'History', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              }),
              _buildDrawerItem(context, Icons.bloodtype, 'Blood Compatibility Chart', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CompatibilityChartPage()),
                );
              }),
              _buildDrawerItem(context, Icons.local_hospital, 'Hospitals and Donation Centers', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DonationCentersPage()),
                );
              }),
              _buildDrawerItem(context, Icons.message, 'Messages', () {
                Navigator.pop(context);
                homeState?._changePage(2);
              }),
              Divider(color: isDarkMode ? Colors.grey[800] : Colors.grey[300]),
              _buildDrawerItem(context, Icons.people, 'Donors', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DonorsPage()),
                );
              }),
              _buildDrawerItem(context, Icons.settings, 'Settings', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              }),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Red background with illustration
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFCC2B2B),
                  Color(0xFFE53935),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCC2B2B).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -50,
                  top: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        FontAwesomeIcons.handHoldingMedical,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Save Lives',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Donate Blood Today',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Grid of menu items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildMenuCard(context, Icons.favorite, 'Donate'),
                  _buildMenuCard(context, Icons.send, 'Request'),
                  _buildMenuCard(context, Icons.location_on, 'Donation\nCentres'),
                  _buildMenuCard(context, Icons.open_in_full, 'Active\nRequests'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFFCC2B2B)),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String title) {
    const color = Color(0xFFCC2B2B);
    return Card(
      elevation: 8,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          switch (title) {
            case 'Request':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RequestBloodPage()),
              );
              break;
            case 'Donate':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DonatePage()),
              );
              break;
            case 'Active\nRequests':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActiveRequestsPage()),
              );
              break;
            case 'Donation\nCentres':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DonationCentersPage()),
              );
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title feature coming soon!')),
              );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
