import 'package:flutter/material.dart';
import '../../responsive/responsive.dart';
import '../../models/topic_model.dart';

import '../feedback/feedback_form_page.dart';

import '../widgets/module_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/top_bar.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key});

  static final List<TopicModel> topics = [
    TopicModel(
      num: 1,
      name: 'Version Control System',
      enabled: true,
      done: false,
    ),
    TopicModel(
      num: 2,
      name: 'Introduction',
      enabled: false,
      done: false,
    ),
    TopicModel(
      num: 3,
      name: 'Workflow',
      enabled: false,
      done: false,
    ),
    TopicModel(
      num: 4,
      name: 'Branching & Merging',
      enabled: false,
      done: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: 'Google Flutter',
            onBack: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      Responsive.isDesktop(context) ? 850 : double.infinity,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const ProgressCard(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Modules',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111111),
                              ),
                            ),
                            const SizedBox(height: 10),

                            ModuleCard(
                              icon: Icons.code,
                              name: 'Git & GitHub',
                              progress: 0.6,
                              expanded: true,
                              topics: topics,
                              onFeedback: (topicName) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FeedbackFormPage(
                                      courseName: 'Git & GitHub',
                                      topicName: topicName,
                                      classId: 'class-git-001',
                                      studentId: 'student-001',
                                      mentorId: 'mentor-001',
                                    ),
                                  ),
                                );
                              },
                            ),

                            const ModuleCard(
                              icon: Icons.flutter_dash,
                              name: 'Dart Programming',
                              progress: 0.8,
                            ),

                            const ModuleCard(
                              icon: Icons.phone_android,
                              name: 'Intro to Flutter',
                              progress: 0.4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 