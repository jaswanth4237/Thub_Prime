import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class FeedbackService {
  static final String _apiBaseUrl = getApiBaseUrl();

  /// Submit feedback to backend
  /// Data will be sent to Kafka for async processing (encryption and storage)
  static Future<void> submitFeedback({
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'classId': classId,
          'studentId': studentId,
          'mentorId': mentorId,
          'rating': rating,
          'comments': comments,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Backend error ${response.statusCode}: ${response.body}',
        );
      }

      final Map<String, dynamic> payload = jsonDecode(response.body);

      if (payload['success'] != true) {
        throw Exception(
          payload['message'] ?? 'Failed to submit feedback',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
