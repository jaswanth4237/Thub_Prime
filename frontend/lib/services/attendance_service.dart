import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AttendanceService {
  static final String _apiBaseUrl = getApiBaseUrl();

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
