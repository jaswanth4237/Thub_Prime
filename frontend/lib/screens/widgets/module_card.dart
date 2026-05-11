import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/topic_model.dart';
import 'topic_row.dart';

class ModuleCard extends StatefulWidget {
  final IconData? icon;
  final String? iconUrl;
  final String name;
  final double progress;
  final List<TopicModel>? topics;
  final void Function(String topicName)? onFeedback;

  const ModuleCard({
    super.key,
    this.icon,
    this.iconUrl,
    required this.name,
    required this.progress,
    this.topics,
    this.onFeedback,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: kAmber.withOpacity(0.5), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: widget.iconUrl != null && widget.iconUrl!.isNotEmpty
                        ? (widget.iconUrl!.startsWith('assets/')
                            ? Image.asset(
                                widget.iconUrl!,
                                fit: BoxFit.contain,
                              )
                            : Image.network(
                                widget.iconUrl!,
                                fit: BoxFit.contain,
                              ))
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _expanded = !_expanded),
                              child: Icon(
                                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: kGreen,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 80,
                          height: 4,
                          decoration: BoxDecoration(
                            color: kGrayBg,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: widget.progress.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: kGreen,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_expanded && widget.topics != null)
                Padding(
                  padding: const EdgeInsets.only(left: 65, top: 10),
                  child: Column(
                    children: widget.topics!.asMap().entries.map((entry) {
                      TopicModel topic = entry.value;
                      return TopicRow(
                        topic: topic,
                        onTap: widget.onFeedback != null
                            ? () => widget.onFeedback!(topic.name)
                            : null,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
