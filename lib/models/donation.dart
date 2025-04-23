import 'package:cloud_firestore/cloud_firestore.dart';

class Donation {
  final String id;
  final String userId;
  final String type;
  final String description;
  final String location;
  final DateTime date;
  final String status;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Personal Information
  final String? bloodType;
  final String? gender;
  final int? age;
  final double? weight;
  final DateTime? lastDonationDate;

  // Health Information
  final bool? hasRecentSurgery;
  final bool? hasChronicDisease;
  final bool? isPregnant;
  final bool? hasTattoo;
  final DateTime? lastMealTime;

  Donation({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.location,
    required this.date,
    required this.status,
    this.imageUrl,
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
    this.lastMealTime,
  });

  factory Donation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Donation(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? '',
      imageUrl: data['imageUrl'],
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
      lastMealTime: data['lastMealTime'] != null
          ? (data['lastMealTime'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'status': status,
      'imageUrl': imageUrl,
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
      'lastMealTime':
          lastMealTime != null ? Timestamp.fromDate(lastMealTime!) : null,
    };
  }
}
