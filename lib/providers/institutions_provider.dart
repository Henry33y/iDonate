import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InstitutionsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<Map<String, dynamic>> _institutions = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get institutions => _institutions;

  // Initialize the provider
  InstitutionsProvider() {
    _loadInstitutions();
  }

  Future<void> _loadInstitutions() async {
    try {
      _isLoading = true;
      notifyListeners();

      final QuerySnapshot snapshot =
          await _firestore.collection('institutions').get();

      _institutions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'type': data['type'] ?? 'Unknown',
          'address': data['address'] ?? 'No address',
          'rating': (data['rating'] ?? 0.0).toDouble(),
          'reviews': data['reviews'] ?? 0,
          'status': (data['isOpen'] as bool? ?? false) ? 'Open' : 'Closed',
          'hours': data['hours'] ?? 'Not specified',
          'phone': data['phone'] ?? 'Not available',
          'website': data['website'] ?? 'Not available',
          'services': List<String>.from(data['services'] ?? []),
          'bloodTypes': List<String>.from(data['bloodTypes'] ?? []),
          'waitTime': data['waitTime'] ?? 'Not available',
        };
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading institutions: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
 