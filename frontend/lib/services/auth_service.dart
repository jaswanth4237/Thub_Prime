import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';

class AuthService {
  static final String _loginUrl = dotenv.get('AUTH_API_URL', fallback: 'https://aihoot.in:5001/api/login');

  /// Performs login and stores user data locally if successful
  static Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Final structure depends on whether the API returns user directly or in a nested field
        // The user provided the object directly as "login info", so assuming it's the root or inside 'data'
        final userJson = data.containsKey('student_id') ? data : data['user'] ?? data['data'];
        
        if (userJson != null) {
          final user = UserModel.fromJson(userJson);
          await _saveUserSession(user);
          return user;
        }
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// Saves user information to persistent storage
  static Future<void> _saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    await prefs.setString('student_id', user.studentId);
  }

  /// Retrieves the current logged-in user if available
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('user_data');
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  /// Clears the user session
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
