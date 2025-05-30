import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'pages/appointments_page.dart';
import 'pages/messages_page.dart';
import 'pages/profile_page.dart';
import 'pages/notifications_page.dart';
import 'pages/history_page.dart';
import 'pages/compatibility_chart_page.dart';
import 'pages/request_blood_page.dart';
import 'pages/donate_page.dart';
import 'pages/donation_centers_page.dart';
import 'pages/donors_page.dart';
import 'pages/settings_page.dart';
import 'pages/active_requests_page.dart';
import 'main.dart'; // Import for ThemeProvider
import 'widgets/hover_button.dart'; // Import the new HoverButton widget
import 'providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _pages = [
    const HomeContent(),
    const AppointmentsPage(),
    const MessagesPage(),
    const ProfilePage(),
  ];

  String getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'Guest';
  }

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onDrawerItemTap(Widget page) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Theme(
      data: isDarkMode
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
      child: Stack(
        children: [
          // Subtle background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFCC2B2B),
                  Colors.white,
                ],
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFFCC2B2B),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 8),
                        Icon(Icons.bloodtype, color: Colors.white, size: 40),
                        SizedBox(height: 12),
                        Text(
                          'iDonate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.history, color: Color(0xFFCC2B2B)),
                    title: const Text('History'),
                    onTap: () => _onDrawerItemTap(const HistoryPage()),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.bloodtype, color: Color(0xFFCC2B2B)),
                    title: const Text('Blood Compatibility Chart'),
                    onTap: () =>
                        _onDrawerItemTap(const CompatibilityChartPage()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_hospital,
                        color: Color(0xFFCC2B2B)),
                    title: const Text('Hospitals and Donation Centers'),
                    onTap: () => _onDrawerItemTap(const DonationCentersPage()),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.message, color: Color(0xFFCC2B2B)),
                    title: const Text('Messages'),
                    onTap: () => _onDrawerItemTap(const MessagesPage()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people, color: Color(0xFFCC2B2B)),
                    title: const Text('Donors'),
                    onTap: () => _onDrawerItemTap(const DonorsPage()),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.assignment, color: Color(0xFFCC2B2B)),
                    title: const Text('Active Requests'),
                    onTap: () => _onDrawerItemTap(const ActiveRequestsPage()),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.settings, color: Color(0xFFCC2B2B)),
                    title: const Text('Settings'),
                    onTap: () => _onDrawerItemTap(const SettingsPage()),
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xFFCC2B2B),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: Row(
                children: [
                  const Icon(Icons.bloodtype, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'iDonate',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const Spacer(),
                  // User greeting and avatar
                  // Text(
                  //   'Hi,  0${getUserName()}',
                  //   style: const TextStyle(
                  //     color: Colors.white,
                  //     fontWeight: FontWeight.w500,
                  //     fontSize: 16,
                  //   ),
                  // ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: Icon(Icons.person, color: Color(0xFFCC2B2B)),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const NotificationsPage()),
                    );
                  },
                ),
                // IconButton(
                //   icon: Icon(
                //     themeProvider.isDarkMode
                //         ? Icons.light_mode
                //         : Icons.dark_mode,
                //     color: Colors.white,
                //   ),
                //   onPressed: () {
                //     themeProvider.toggleTheme();
                //   },
                // ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                // You can add logic to refresh data here if needed
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _pages[_currentIndex],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFFCC2B2B),
              child: const Icon(Icons.location_on, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Find nearby donation centers coming soon!'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFFCC2B2B),
                  ),
                );
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFFCC2B2B),
              unselectedItemColor: Colors.grey,
              currentIndex: _currentIndex,
              onTap: _changePage,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Appointments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  String getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'Guest';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white, // solid background for clarity
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Greeting and avatar above the header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFCC2B2B),
                      radius: 20,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hi, ${getUserName()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Red header with Save Lives section and gradient
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFCC2B2B),
                      Color(0xFFCC2B2B),
                      Color(0xFFCC2B2B),
                      Color(0x00CC2B2B), // fade out
                    ],
                    stops: [0, 0.7, 0.9, 1],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: const Icon(Icons.health_and_safety,
                          color: Colors.white, size: 56),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Save Lives',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Donate Blood Today',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              // Four main action cards in a 2x2 grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _HomeActionCard(
                            icon: Icons.favorite,
                            label: 'Donate',
                            color: const Color(0xFFCC2B2B),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const DonatePage()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _HomeActionCard(
                            icon: Icons.send,
                            label: 'Request',
                            color: Colors.redAccent,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RequestBloodPage()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _HomeActionCard(
                            icon: Icons.location_on,
                            label: 'Donation Centres',
                            color: Colors.red.shade200,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const DonationCentersPage()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _HomeActionCard(
                            icon: Icons.assignment,
                            label: 'Active Requests',
                            color: Colors.red.shade100,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ActiveRequestsPage()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _HomeActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.18)),
          // Glassmorphism effect
          backgroundBlendMode: BlendMode.overlay,
        ),
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Montserrat',
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
