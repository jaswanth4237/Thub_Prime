import 'topic_model.dart';

class CourseModule {
  final String id;
  final String batchName;
  final String courseName;
  final String technologyName;
  final String technologyIcon;
  final String moduleName;
  final String moduleId;
  final String moduleIcon;
  final List<TopicModel> topics;

  CourseModule({
    required this.id,
    required this.batchName,
    required this.courseName,
    required this.technologyName,
    required this.technologyIcon,
    required this.moduleName,
    required this.moduleId,
    required this.moduleIcon,
    required this.topics,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    var topicList = json['topic'] as List? ?? [];
    List<TopicModel> topics = topicList.asMap().entries.map((entry) {
      int idx = entry.key;
      var t = entry.value;
      return TopicModel.fromJson(t, idx + 1);
    }).toList();

    return CourseModule(
      id: json['_id'] ?? '',
      batchName: json['batch_name'] ?? '',
      courseName: json['course_name'] ?? '',
      technologyName: json['technology_name'] ?? '',
      technologyIcon: json['technology_icon'] ?? '',
      moduleName: json['module_name'] ?? '',
      moduleId: json['module_id'] ?? '',
      moduleIcon: json['module_icon'] ?? '',
      topics: topics,
    );
  }

  double get progress {
    if (topics.isEmpty) return 0.0;
    int total = topics.length;
    int doneCount = topics.where((t) => t.done).length;
    return doneCount / total;
  }
}
