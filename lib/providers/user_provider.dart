import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void setUser(User? user) {
    _user = user;
    _error = null;
    notifyListeners();
  }

  void setUserData(Map<String, dynamic>? userData) {
    _userData = userData;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void signOut() {
    _user = null;
    _userData = null;
    _error = null;
    notifyListeners();
  }
}
