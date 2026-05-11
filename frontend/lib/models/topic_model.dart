class TopicModel {
  final int num;
  final String name;
  final bool enabled;
  final bool done;

  TopicModel({
    required this.num,
    required this.name,
    required this.enabled,
    required this.done,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json, int index) {
    int total = json['total_sessions'] ?? 0;
    int attended = json['attended_count'] ?? 0;
    
    return TopicModel(
      num: index,
      name: json['topic_name'] ?? 'Unknown Topic',
      enabled: attended > 0,
      done: total > 0 && attended == total,
    );
  }
}