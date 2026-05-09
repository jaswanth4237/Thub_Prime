import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/topic_model.dart';
import 'topic_row.dart';

class ModuleCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final double progress;
  final bool expanded;
  final List<TopicModel>? topics;
  final void Function(String)? onFeedback;

  const ModuleCard({
    super.key,
    required this.icon,
    required this.name,
    required this.progress,
    this.expanded = false,
    this.topics,
    this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kAmber, width: 2),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: kAmber, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: kGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: kBorder,
                          valueColor: const AlwaysStoppedAnimation(kGreen),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: kGreen,
                  size: 20,
                ),
              ],
            ),
          ),
          if (expanded && topics != null)
            ...topics!.map(
              (topic) => TopicRow(
                topic: topic,
                onTap: (topic.enabled && !topic.done)
                    ? () => onFeedback?.call(topic.name)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}