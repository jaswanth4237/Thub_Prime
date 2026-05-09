import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/topic_model.dart';
import 'feedback_pill.dart';

class TopicRow extends StatelessWidget {
  final TopicModel topic;
  final VoidCallback? onTap;

  const TopicRow({
    super.key,
    required this.topic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          height: 1,
          color: Color(0xFFF0F0F0),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                child: Text(
                  '${topic.num}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: topic.enabled
                        ? const Color(0xFF111111)
                        : kDimText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  topic.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: topic.enabled
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: topic.enabled
                        ? const Color(0xFF111111)
                        : kDimText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FeedbackPill(
                enabled: topic.enabled,
                done: topic.done,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}