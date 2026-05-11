import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/course_module.dart';

class CourseService {
  static final String _sessionApiUrl = dotenv.get('MAYA_API_URL');

  /// Fetch course modules and session data for a student
  static Future<List<CourseModule>> getStudentSessions(String studentId) async {
    try {
      final response = await http.post(
        Uri.parse(_sessionApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'studentId': studentId}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        debugPrint('CourseService: session API returned ${response.statusCode}');
        return _demoModules();
      }

      final dynamic data = jsonDecode(response.body);

      if (data is List) {
        if (data.isNotEmpty && data[0] is List) {
          final List<dynamic> modulesJson = data[0];
          final modules = modulesJson
              .whereType<Map<String, dynamic>>()
              .map(CourseModule.fromJson)
              .toList();
          return modules.isNotEmpty ? modules : _demoModules();
        }

        final modules = data
            .whereType<Map<String, dynamic>>()
            .map(CourseModule.fromJson)
            .toList();
        return modules.isNotEmpty ? modules : _demoModules();
      }

      if (data is Map<String, dynamic>) {
        final dynamic nested = data['data'];
        if (nested is List) {
          if (nested.isNotEmpty && nested[0] is List) {
            final modules = (nested[0] as List)
                .whereType<Map<String, dynamic>>()
                .map(CourseModule.fromJson)
                .toList();
            return modules.isNotEmpty ? modules : _demoModules();
          }

          final modules = nested
              .whereType<Map<String, dynamic>>()
              .map(CourseModule.fromJson)
              .toList();
          return modules.isNotEmpty ? modules : _demoModules();
        }
      }

      return _demoModules();
    } catch (e) {
      debugPrint('CourseService: falling back to demo modules after error: $e');
      return _demoModules();
    }
  }

  static List<CourseModule> _demoModules() {
    const String jsonSource = '''
[
    {
        "_id": "6815ba461388f49e843c95a6",
        "batch_name": "DR_2027_FLUTTER",
        "course_name": "Drive Ready",
        "technology_name": "Google Flutter",
        "technology_icon": "https://maya.technicalhub.io/node/technology-icons/a34119719fbc244f3d65ab0860b20fda.png",
        "module_name": "Git & Git Hub",
        "module_id": "664ef84a31dbbb73deeaca89",
        "module_icon": "assets/images/git_github.png",
        "topic": [
            {"topic_name": "Version Control System", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Introduction", "total_sessions": 0, "attended_count": 0},
            {"topic_name": "Workflow", "total_sessions": 2, "attended_count": 2},
            {"topic_name": "Braching & Merging", "total_sessions": 2, "attended_count": 2}
        ]
    },
    {
        "_id": "6815ba461388f49e843c95a6",
        "batch_name": "DR_2027_FLUTTER",
        "course_name": "Drive Ready",
        "technology_name": "Google Flutter",
        "technology_icon": "https://maya.technicalhub.io/node/technology-icons/a34119719fbc244f3d65ab0860b20fda.png",
        "module_name": "Dart Programming",
        "module_id": "664ef92c31dbbb73deeae3b8",
        "module_icon": "assets/images/dart.png",
        "topic": [
            {"topic_name": "Intro to Dart", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Methods to run Dart", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Data Types", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Operators", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Conditional Statements", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Control Statements", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Strings", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Lists", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Maps", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Functions", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "OOPs Concepts", "total_sessions": 2, "attended_count": 2},
            {"topic_name": "Async & Await", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Exception Handling", "total_sessions": 2, "attended_count": 2}
        ]
    },
    {
        "module_name": "Intro to Flutter",
        "module_id": "664ef92c31dbbb73deeae3b9",
        "module_icon": "assets/images/flutter.png",
        "topic": [
            {"topic_name": "Environment setup ", "total_sessions": 3, "attended_count": 3},
            {"topic_name": "Understanding Flutter", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Intro to Widgets", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Creating a project ", "total_sessions": 1, "attended_count": 1}
        ]
    },
    {
        "module_name": "Widget",
        "module_id": "664ef92c31dbbb73deeae3c0",
        "module_icon": "assets/images/widget.png",
        "topic": [
            {"topic_name": "Material Widgets", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "Cupertino Widgets", "total_sessions": 2, "attended_count": 2},
            {"topic_name": "Stateless & Stateful Widgets", "total_sessions": 1, "attended_count": 1}
        ]
    },
    {
        "module_name": "AI Integration",
        "module_id": "664ef92c31dbbb73deeae3c1",
        "module_icon": "https://maya.technicalhub.io/node/module-icons/d15b6a5e53f41868679e7b9bd5ea1b2c.png",
        "topic": [
            {"topic_name": "Intro to Generative AI", "total_sessions": 1, "attended_count": 1},
            {"topic_name": "HTTP Methods", "total_sessions": 8, "attended_count": 8},
            {"topic_name": "Prompt to Text", "total_sessions": 2, "attended_count": 1}
        ]
    }
]
''';
    final List<dynamic> data = jsonDecode(jsonSource);
    return data.map((m) => CourseModule.fromJson(m)).toList();
  }
}
