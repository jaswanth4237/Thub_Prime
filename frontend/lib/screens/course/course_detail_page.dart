import 'package:flutter/material.dart';
import '../../responsive/responsive.dart';
import '../../models/topic_model.dart';
import '../../services/feedback_service.dart';

import '../feedback/feedback_form_page.dart';
import '../blockScreen.dart';

import '../widgets/module_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/top_bar.dart';

class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({super.key});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool _isCheckingStatus = true;
  final String _studentId = 'student-001'; // In real app, get from auth

  static final List<TopicModel> topics = [
    TopicModel(num: 1, name: 'Version Control System', enabled: true, done: false),
    TopicModel(num: 2, name: 'Introduction', enabled: false, done: false),
    TopicModel(num: 3, name: 'Workflow', enabled: false, done: false),
    TopicModel(num: 4, name: 'Branching & Merging', enabled: false, done: false),
  ];

  @override
  void initState() {
    super.initState();
    _checkBlockedStatus();
  }

  Future<void> _checkBlockedStatus() async {
    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final status = await FeedbackService.checkBlockedStatus(_studentId);
      
      if (status['success'] == true && status['isBlocked'] == true) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlockScreen(
              studentId: _studentId,
              classId: status['classId'] ?? 'unknown',
              reason: status['message'] ?? 'Please provide feedback for previous session.',
            ),
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint('Error checking blocked status: $e');
    }

    if (mounted) {
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingStatus) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff14973a)),
          ),
        ),
      );
    }

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
                  maxWidth: Responsive.isDesktop(context) ? 850 : double.infinity,
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
                                      studentId: _studentId,
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