import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  // Key for storing current user in SharedPreferences
  static const String _currentUserKey = 'current_user';

  // Current user
  User? _currentUser;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  // Constructor - loads saved user
  AuthProvider() {
    _loadCurrentUser();
  }

  // Load current user from SharedPreferences
  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);

      if (userJson != null) {
        _currentUser = User.fromJson(Map<String, dynamic>.from(
            Map.castFrom(await jsonDecode(userJson))));
      }
    } catch (e) {
      // Handle error
      print('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save current user to SharedPreferences
  Future<void> _saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    if (_currentUser != null) {
      await prefs.setString(
          _currentUserKey, jsonEncode(_currentUser!.toJson()));
    } else {
      await prefs.remove(_currentUserKey);
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.login(email, password);

      if (user != null) {
        _currentUser = user;
        await _saveCurrentUser();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register user
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newUser = User(
        name: name,
        email: email,
        password: password,
      );

      final success = await AuthService.saveUser(newUser);

      if (success) {
        _currentUser = newUser;
        await _saveCurrentUser();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = null;
      await _saveCurrentUser();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
