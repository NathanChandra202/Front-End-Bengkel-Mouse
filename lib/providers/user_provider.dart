import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String get name => _user?['name'] ?? '';
  String get email => _user?['email'] ?? '';
  String get phone => _user?['phone'] ?? '';
  String get address => _user?['address'] ?? '';
  String get role => _user?['role'] ?? 'USER';
  bool get isAdmin => role == 'ADMIN';

  String get initials {
    final n = name;
    if (n.isEmpty) return '?';
    final parts = n.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return n[0].toUpperCase();
  }

  /// Set user directly after login (from login response)
  void setUser(Map<String, dynamic> userData) {
    _user = userData;
    notifyListeners();
  }

  /// Fetch user profile from backend
  Future<void> fetchUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _user = null;
      } else {
        final data = await ApiService.getMe();
        _user = data['user'];
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
      _user = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Update profile (name, phone, address)
  Future<void> updateProfile({String? name, String? phone, String? address}) async {
    final data = await ApiService.updateProfile(name: name, phone: phone, address: address);
    if (_user != null && data['user'] != null) {
      _user = {..._user!, ...data['user']};
      notifyListeners();
    }
  }

  /// Clear user on logout
  Future<void> logout() async {
    await ApiService.removeToken();
    _user = null;
    notifyListeners();
  }
}
