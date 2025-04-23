import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Donation eligibility information
  final String? bloodType;
  final String? gender;
  final int? age;
  final double? weight;
  final DateTime? lastDonationDate;
  final bool? hasRecentSurgery;
  final bool? hasChronicDisease;
  final bool? isPregnant;
  final bool? hasTattoo;
  final bool isEligible;
  final String anonymizedUsername;

  // Achievement and verification information
  final int donationCount;
  final int livesSaved;
  final List<String> achievements;
  final bool isHospitalVerified;
  final String? verifiedBy;
  final DateTime? verificationDate;
  final String verificationLevel;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.bloodType,
    this.gender,
    this.age,
    this.weight,
    this.lastDonationDate,
    this.hasRecentSurgery,
    this.hasChronicDisease,
    this.isPregnant,
    this.hasTattoo,
    required this.isEligible,
    required this.anonymizedUsername,
    this.donationCount = 0,
    this.livesSaved = 0,
    this.achievements = const [],
    this.isHospitalVerified = false,
    this.verifiedBy,
    this.verificationDate,
    this.verificationLevel = 'Not Verified',
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      bloodType: data['bloodType'],
      gender: data['gender'],
      age: data['age'],
      weight: data['weight'],
      lastDonationDate: data['lastDonationDate'] != null
          ? (data['lastDonationDate'] as Timestamp).toDate()
          : null,
      hasRecentSurgery: data['hasRecentSurgery'],
      hasChronicDisease: data['hasChronicDisease'],
      isPregnant: data['isPregnant'],
      hasTattoo: data['hasTattoo'],
      isEligible: data['isEligible'] ?? false,
      anonymizedUsername:
          data['anonymizedUsername'] ?? 'Donor#${doc.id.substring(0, 4)}',
      donationCount: data['donationCount'] ?? 0,
      livesSaved: data['livesSaved'] ?? 0,
      achievements: List<String>.from(data['achievements'] ?? []),
      isHospitalVerified: data['isHospitalVerified'] ?? false,
      verifiedBy: data['verifiedBy'],
      verificationDate: data['verificationDate'] != null
          ? (data['verificationDate'] as Timestamp).toDate()
          : null,
      verificationLevel: data['verificationLevel'] ?? 'Not Verified',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'bloodType': bloodType,
      'gender': gender,
      'age': age,
      'weight': weight,
      'lastDonationDate': lastDonationDate != null
          ? Timestamp.fromDate(lastDonationDate!)
          : null,
      'hasRecentSurgery': hasRecentSurgery,
      'hasChronicDisease': hasChronicDisease,
      'isPregnant': isPregnant,
      'hasTattoo': hasTattoo,
      'isEligible': isEligible,
      'anonymizedUsername': anonymizedUsername,
      'donationCount': donationCount,
      'livesSaved': livesSaved,
      'achievements': achievements,
      'isHospitalVerified': isHospitalVerified,
      'verifiedBy': verifiedBy,
      'verificationDate': verificationDate != null
          ? Timestamp.fromDate(verificationDate!)
          : null,
      'verificationLevel': verificationLevel,
    };
  }

  // Achievement check methods
  bool get hasFirstDonationAchievement => donationCount >= 1;
  bool get hasRegularDonorAchievement => donationCount >= 5;
  bool get hasLifeSaverAchievement => livesSaved >= 10;
  bool get hasHospitalVerificationAchievement => isHospitalVerified;

  // Get all earned achievements
  List<String> get earnedAchievements {
    final earned = <String>[];
    if (hasFirstDonationAchievement) earned.add('First Donation');
    if (hasRegularDonorAchievement) earned.add('Regular Donor');
    if (hasLifeSaverAchievement) earned.add('Life Saver');
    if (hasHospitalVerificationAchievement) earned.add('Hospital Verified');
    return earned;
  }
}
