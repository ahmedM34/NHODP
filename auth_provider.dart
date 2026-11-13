import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  String get userName => _user?['full_name'] ?? 'Guest';
  String get userEmail => _user?['email'] ?? '';
  String get userRole => _user?['role'] ?? 'public';

  AuthProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final email = prefs.getString('user_email');
    final name = prefs.getString('user_name');
    final role = prefs.getString('user_role');
    if (_token != null && email != null) {
      _isAuthenticated = true;
      _user = {'email': email, 'full_name': name ?? '', 'role': role ?? 'public'};
      notifyListeners();
      try {
        final fresh = await ApiService.getCurrentUser();
        _user = fresh;
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await ApiService.login(email, password);
      if (result['success'] == true) {
        _token = result['access_token'];
        _isAuthenticated = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_email', email);
        await prefs.setString('user_role', result['role'] ?? 'public');
        try {
          _user = await ApiService.getCurrentUser();
          await prefs.setString('user_name', _user?['full_name'] ?? '');
        } catch (_) {
          _user = {'email': email, 'role': result['role'] ?? 'public'};
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['detail'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Is the backend running?';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({required String email, required String password, required String fullName, String? institution}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await ApiService.register({
        'email': email,
        'password': password,
        'full_name': fullName,
        'institution': institution,
      });
      _isLoading = false;
      if (result['success'] == true) {
        notifyListeners();
        return true;
      } else {
        _error = result['detail'] ?? 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _user = null;
    _token = null;
    _error = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
