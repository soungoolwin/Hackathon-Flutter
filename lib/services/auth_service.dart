import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'users';

  // Initialize with default user
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_usersKey)) {
      // Create default user
      final defaultUser = User(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password',
      );

      // Save default user
      await saveUser(defaultUser);
    }
  }

  // Get all users
  static Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null) {
      return [];
    }

    final List<dynamic> usersList = json.decode(usersJson);
    return usersList.map((userMap) => User.fromJson(userMap)).toList();
  }

  // Save a new user
  static Future<bool> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();

    // Check if user with this email already exists
    if (users.any((u) => u.email == user.email)) {
      return false; // User already exists
    }

    users.add(user);
    final usersJson = json.encode(users.map((u) => u.toJson()).toList());
    return await prefs.setString(_usersKey, usersJson);
  }

  // Login validation
  static Future<User?> login(String email, String password) async {
    final users = await getUsers();

    try {
      return users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null; // User not found or password incorrect
    }
  }
}
