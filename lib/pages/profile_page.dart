import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../providers/users_provider.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  String? _selectedGender;
  bool _hasRecentSurgery = false;
  bool _hasChronicDisease = false;
  bool _isPregnant = false;
  bool _hasTattoo = false;
  bool _isEditing = false;
  String _lastUserId = '';

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  final List<Map<String, dynamic>> _achievementTypes = [
    {
      'id': 'first_donation',
      'icon': FontAwesomeIcons.droplet,
      'title': 'First Donation',
      'description': 'Complete your first blood donation',
      'color': const Color(0xFFE53935),
      'requirement': '1 donation',
    },
    {
      'id': 'regular_donor',
      'icon': FontAwesomeIcons.award,
      'title': 'Regular Donor',
      'description': 'Make 5 or more donations',
      'color': const Color(0xFFFFB300),
      'requirement': '5 donations',
    },
    {
      'id': 'life_saver',
      'icon': FontAwesomeIcons.heartPulse,
      'title': 'Life Saver',
      'description': 'Help save 10 or more lives',
      'color': const Color(0xFF43A047),
      'requirement': '10 lives saved',
    },
    {
      'id': 'hospital_verified',
      'icon': FontAwesomeIcons.hospital,
      'title': 'Hospital Verified',
      'description': 'Verified by partner hospital',
      'color': const Color(0xFF1E88E5),
      'requirement': 'Hospital verification',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _displayNameController = TextEditingController();
    _bloodTypeController = TextEditingController();
    _ageController = TextEditingController();
    _weightController = TextEditingController();
  }

  void _updateControllers(User user) {
    _displayNameController.text = user.displayName ?? '';
    _bloodTypeController.text = user.bloodType ?? '';
    _ageController.text = user.age?.toString() ?? '';
    _weightController.text = user.weight?.toString() ?? '';
    _selectedGender = user.gender;
    _hasRecentSurgery = user.hasRecentSurgery ?? false;
    _hasChronicDisease = user.hasChronicDisease ?? false;
    _isPregnant = user.isPregnant ?? false;
    _hasTattoo = user.hasTattoo ?? false;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bloodTypeController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final usersProvider =
            Provider.of<UsersProvider>(context, listen: false);

        try {
          await usersProvider.createOrUpdateUser(
            userId: currentUser.uid,
            email: currentUser.email ?? '',
            displayName: _displayNameController.text,
            bloodType: _bloodTypeController.text,
            gender: _selectedGender,
            age: int.tryParse(_ageController.text),
            weight: double.tryParse(_weightController.text),
            hasRecentSurgery: _hasRecentSurgery,
            hasChronicDisease: _hasChronicDisease,
            isPregnant: _isPregnant,
            hasTattoo: _hasTattoo,
          );

          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      }
    }
  }

  Widget _buildVerificationBadge(User user) {
    final verificationLevel = _calculateVerificationLevel(user);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: verificationLevel.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: verificationLevel.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verificationLevel.icon,
            size: 16,
            color: verificationLevel.color,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                verificationLevel.text,
                style: TextStyle(
                  color: verificationLevel.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (user.isHospitalVerified && user.verifiedBy != null)
                Text(
                  'Verified by ${user.verifiedBy}',
                  style: TextStyle(
                    color: verificationLevel.color,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  VerificationLevel _calculateVerificationLevel(User user) {
    if (!user.isEligible) {
      return VerificationLevel(
        text: 'Not Verified',
        color: Colors.grey,
        icon: Icons.cancel,
      );
    }

    if (user.isHospitalVerified) {
      return VerificationLevel(
        text: 'Hospital Verified',
        color: const Color(0xFF1E88E5),
        icon: Icons.verified_user,
      );
    }

    final hasBasicInfo = user.bloodType != null &&
        user.gender != null &&
        user.age != null &&
        user.weight != null;

    if (!hasBasicInfo) {
      return VerificationLevel(
        text: 'Basic Info Required',
        color: Colors.orange,
        icon: Icons.info,
      );
    }

    return VerificationLevel(
      text: 'Verified Donor',
      color: Colors.green,
      icon: Icons.verified,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view your profile'),
        ),
      );
    }

    return Consumer<UsersProvider>(
      builder: (context, usersProvider, child) {
        User user;
        try {
          user = usersProvider.eligibleDonors.firstWhere(
            (u) => u.id == currentUser.uid,
          );
        } catch (e) {
          // If user not found, create a new user object
          user = User(
            id: currentUser.uid,
            email: currentUser.email ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isEligible: false,
            anonymizedUsername: 'Donor#${currentUser.uid.substring(0, 4)}',
          );

          // Create the user document in Firestore
          WidgetsBinding.instance.addPostFrameCallback((_) {
            usersProvider.createOrUpdateUser(
              userId: currentUser.uid,
              email: currentUser.email ?? '',
            );
          });
        }

        // Only update controllers if the user data has changed
        if (user.id != _lastUserId) {
          _lastUserId = user.id;
          _updateControllers(user);
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFCC2B2B),
            elevation: 0,
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _isEditing ? Icons.close : Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (mounted) {
                      setState(() => _isEditing = !_isEditing);
                    }
                  },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFCC2B2B),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              user.displayName?.substring(0, 1).toUpperCase() ??
                                  'D',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFCC2B2B),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFCC2B2B),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Color(0xFFCC2B2B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName ?? 'Donor',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildVerificationBadge(user),
                    ],
                  ),
                ),
                if (_isEditing)
                  _buildEditForm(user)
                else
                  _buildProfileContent(user),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(User user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStats(user),
          const SizedBox(height: 24),
          _buildAchievements(user),
        ],
      ),
    );
  }

  Widget _buildStats(User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donation Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: FontAwesomeIcons.droplet,
                title: 'Donations',
                value: user.donationCount?.toString() ?? '0',
                color: const Color(0xFFE53935),
              ),
              _buildStatItem(
                icon: FontAwesomeIcons.heartPulse,
                title: 'Lives Saved',
                value: user.livesSaved?.toString() ?? '0',
                color: const Color(0xFF43A047),
              ),
              _buildStatItem(
                icon: FontAwesomeIcons.award,
                title: 'Achievements',
                value: user.achievements?.length.toString() ?? '0',
                color: const Color(0xFFFFB300),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements(User user) {
    final userAchievements = user.achievements ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _achievementTypes.length,
          itemBuilder: (context, index) {
            final achievement = _achievementTypes[index];
            final isUnlocked = userAchievements.contains(achievement['id']);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? achievement['color'].withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked ? achievement['color'] : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? achievement['color'].withOpacity(0.2)
                          : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      achievement['icon'],
                      color: isUnlocked ? achievement['color'] : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    achievement['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? achievement['color'] : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement['requirement'],
                    style: TextStyle(
                      fontSize: 10,
                      color: isUnlocked ? achievement['color'] : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEditForm(User user) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _bloodTypeController.text.isEmpty
                  ? null
                  : _bloodTypeController.text,
              decoration: const InputDecoration(
                labelText: 'Blood Type',
                border: OutlineInputBorder(),
              ),
              items: _bloodTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _bloodTypeController.text = value ?? '';
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: _genders.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _selectedGender = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter your age';
                final age = int.tryParse(value);
                if (age == null) return 'Please enter a valid age';
                if (age < 18 || age > 65)
                  return 'Age must be between 18 and 65';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter your weight';
                final weight = double.tryParse(value);
                if (weight == null) return 'Please enter a valid weight';
                if (weight < 50) return 'Weight must be at least 50kg';
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Recent Surgery'),
              value: _hasRecentSurgery,
              onChanged: (value) {
                if (mounted) {
                  setState(() => _hasRecentSurgery = value);
                }
              },
            ),
            SwitchListTile(
              title: const Text('Chronic Disease'),
              value: _hasChronicDisease,
              onChanged: (value) {
                if (mounted) {
                  setState(() => _hasChronicDisease = value);
                }
              },
            ),
            SwitchListTile(
              title: const Text('Pregnant'),
              value: _isPregnant,
              onChanged: (value) {
                if (mounted) {
                  setState(() => _isPregnant = value);
                }
              },
            ),
            SwitchListTile(
              title: const Text('Recent Tattoo'),
              value: _hasTattoo,
              onChanged: (value) {
                if (mounted) {
                  setState(() => _hasTattoo = value);
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCC2B2B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationLevel {
  final String text;
  final Color color;
  final IconData icon;

  VerificationLevel({
    required this.text,
    required this.color,
    required this.icon,
  });
}
