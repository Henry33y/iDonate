import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('iDonate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final role = userData['role'] as String? ?? 'Donor';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Red header with Save Lives section
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCC2B2B),
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
                // User info and stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: role == 'Donor'
                      ? _buildUserInfo(userData)
                      : _buildUserInfo(userData),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: role == 'Donor'
                      ? _buildDonationStats(userData)
                      : _buildRequestStats(userData),
                ),
                const SizedBox(height: 32),
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
                                // TODO: Navigate to donate page
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
                                // TODO: Navigate to request page
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
                                // TODO: Navigate to donation centres page
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
                                // TODO: Navigate to active requests page
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
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(Map<String, dynamic> userData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${userData['name'] ?? 'User'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Blood Type: ${userData['bloodType'] ?? 'Not specified'}'),
            Text('Location: ${userData['location'] ?? 'Not specified'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationStats(Map<String, dynamic> userData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Impact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Donations',
                  (userData['donationCount'] ?? 0).toString(),
                  Icons.favorite,
                ),
                _buildStatCard(
                  'Lives Saved',
                  (userData['livesSaved'] ?? 0).toString(),
                  Icons.people,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestStats(Map<String, dynamic> userData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Active',
                  '0',
                  Icons.access_time,
                ),
                _buildStatCard(
                  'Completed',
                  '0',
                  Icons.check_circle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Colors.red,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
