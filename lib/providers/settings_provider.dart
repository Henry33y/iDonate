import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _smsNotificationsKey = 'sms_notifications';
  static const String _locationKey = 'location_enabled';
  static const String _searchRadiusKey = 'search_radius';
  static const String _languageKey = 'language';
  static const String _unitKey = 'unit';

  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = true;
  bool _locationEnabled = true;
  double _searchRadius = 10.0;
  String _language = 'English';
  String _unit = 'Kilometers';

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get emailNotifications => _emailNotifications;
  bool get smsNotifications => _smsNotifications;
  bool get locationEnabled => _locationEnabled;
  double get searchRadius => _searchRadius;
  String get language => _language;
  String get unit => _unit;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _emailNotifications = prefs.getBool(_emailNotificationsKey) ?? true;
    _smsNotifications = prefs.getBool(_smsNotificationsKey) ?? true;
    _locationEnabled = prefs.getBool(_locationKey) ?? true;
    _searchRadius = prefs.getDouble(_searchRadiusKey) ?? 10.0;
    _language = prefs.getString(_languageKey) ?? 'English';
    _unit = prefs.getString(_unitKey) ?? 'Kilometers';
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _isDarkMode);
    await prefs.setBool(_notificationsKey, _notificationsEnabled);
    await prefs.setBool(_emailNotificationsKey, _emailNotifications);
    await prefs.setBool(_smsNotificationsKey, _smsNotifications);
    await prefs.setBool(_locationKey, _locationEnabled);
    await prefs.setDouble(_searchRadiusKey, _searchRadius);
    await prefs.setString(_languageKey, _language);
    await prefs.setString(_unitKey, _unit);
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setEmailNotifications(bool value) async {
    _emailNotifications = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSmsNotifications(bool value) async {
    _smsNotifications = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLocationEnabled(bool value) async {
    _locationEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSearchRadius(double value) async {
    _searchRadius = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setUnit(String value) async {
    _unit = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_darkModeKey);
    await prefs.remove(_notificationsKey);
    await prefs.remove(_emailNotificationsKey);
    await prefs.remove(_smsNotificationsKey);
    await prefs.remove(_locationKey);
    await prefs.remove(_searchRadiusKey);
    await prefs.remove(_languageKey);
    await prefs.remove(_unitKey);
    await _loadSettings();
  }
}
