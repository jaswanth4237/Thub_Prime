import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../responsive/responsive.dart';
import '../../services/feedback_service.dart';
import '../../services/attendance_service.dart';
import '../../constants/app_colors.dart';

import '../feedback/feedback_form_page.dart';
import '../blockScreen.dart';

import '../widgets/module_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/top_bar.dart';
import '../../providers/course_detail_provider.dart';

class CourseDetailPage extends StatefulWidget {
  final Future<Map<String, dynamic>> Function(String studentId)?
      checkBlockedStatusOverride;
  final Future<Map<String, dynamic>> Function(String studentId)?
      attendanceSummaryOverride;

  const CourseDetailPage({
    super.key,
    this.checkBlockedStatusOverride,
    this.attendanceSummaryOverride,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final provider = context.read<CourseDetailProvider>();
    final status = await provider.checkBlockedStatus(
      overrideFn:
          widget.checkBlockedStatusOverride ??
          FeedbackService.checkBlockedStatus,
    );

    if (!mounted) return;

    if (status['success'] == true && status['isBlocked'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BlockScreen(
            studentId: provider.studentId,
            classId: status['classId'] ?? 'unknown',
            reason:
                status['message'] ??
                'Please provide feedback for previous session.',
          ),
        ),
      );
      return;
    }

    await provider.fetchAttendance(
      overrideFn:
          widget.attendanceSummaryOverride ??
          AttendanceService.getAttendanceSummary,
    );
    await provider.fetchModules();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseDetailProvider>();

    if (provider.isCheckingStatus) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff14973a)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kGrayBg,
      body: Column(
        children: [
          TopBar(
            title: provider.courseName,
            onBack: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.isDesktop(context) ? 850 : double.infinity,
                ),
                child: RefreshIndicator(
                  onRefresh: _initializeData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProgressCard(
                          attendanceRatio: provider.attendanceRatio,
                          percentage: provider.attendancePercentage,
                          isLoading: provider.isLoadingAttendance,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Modules',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: kAmber.withValues(alpha: 0.5), width: 1.5),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: provider.isLoadingModules
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : provider.modules.isEmpty
                                        ? const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(20.0),
                                              child: Text('No modules found'),
                                            ),
                                          )
                                        : Column(
                                            children: provider.modules.map((module) {
                                              return ModuleCard(
                                                iconUrl: module.moduleIcon,
                                                name: module.moduleName,
                                                progress: module.progress,
                                                topics: module.topics,
                                                onFeedback: (topicName) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => FeedbackFormPage(
                                                        courseName: module.moduleName,
                                                        topicName: topicName,
                                                        classId: module.moduleId,
                                                        studentId: provider.studentId,
                                                        mentorId: 'system',
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }).toList(),
                                          ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ],
                    ),
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