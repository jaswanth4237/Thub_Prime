import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AttendanceService {
  static final String _apiBaseUrl = dotenv.get('API_BASE_URL', fallback: 'https://backend-thubprime.onrender.com');

  static Future<Map<String, dynamic>> getAttendanceSummary(String studentId) async {
    try {
      final uri = Uri.parse('$_apiBaseUrl/attendance/summary/$studentId');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to load attendance summary');
    } catch (e) {
      rethrow;
    }
  }
}
