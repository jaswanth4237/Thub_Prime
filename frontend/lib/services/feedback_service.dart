import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FeedbackService {
  static final String _apiBaseUrl = dotenv.get('API_BASE_URL', fallback: 'https://backend-thubprime.onrender.com');

  /// Submit feedback to backend
  /// Data will be sent to Kafka for async processing (encryption and storage)
  static Future<Map<String, dynamic>> submitFeedback({
    required String classId,
    required String studentId,
    required String mentorId,
    required int rating,
    required String comments,
  }) async {
    try {
      final uri = Uri.parse('$_apiBaseUrl/feedback/add');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'classId': classId,
          'studentId': studentId,
          'mentorId': mentorId,
          'rating': rating,
          'comments': comments,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Connection timeout. Please check your internet.'),
      );

      final Map<String, dynamic> payload = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Backend error ${response.statusCode}: ${payload['message'] ?? response.body}',
        );
      }

      if (payload['success'] != true) {
        throw Exception(
          payload['message'] ?? 'Failed to submit feedback',
        );
      }

      return payload;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if student is blocked due to missing previous feedback
  static Future<Map<String, dynamic>> checkBlockedStatus(String studentId) async {
    try {
      final uri = Uri.parse('$_apiBaseUrl/blocked/status/$studentId');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': true, 'isBlocked': false};
    } catch (e) {
      return {'success': false, 'isBlocked': false};
    }
  }
}
