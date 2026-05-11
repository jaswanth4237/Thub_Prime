import 'package:flutter/material.dart';
import '../../responsive/responsive.dart';
import '../../services/feedback_service.dart';
import '../../services/attendance_service.dart';
import '../../constants/app_colors.dart';

import '../feedback/feedback_form_page.dart';
import '../blockScreen.dart';

import '../widgets/module_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/top_bar.dart';
import '../../models/course_module.dart';
import '../../services/course_service.dart';

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
  bool _isCheckingStatus = true;
  bool _isLoadingAttendance = true;
  bool _isLoadingModules = true;
  String _attendanceRatio = '0/0';
  String _attendancePercentage = '0%';
  final String _studentId = '66ed42436aebf032ad4404a8';
  List<CourseModule> _modules = [];
  String _courseName = 'Google Flutter';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _checkBlockedStatus();
    if (mounted && !_isCheckingStatus) {
      _fetchAttendance();
      _fetchModules();
    }
  }

  Future<void> _checkBlockedStatus() async {
    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final status = await (widget.checkBlockedStatusOverride ??
          FeedbackService.checkBlockedStatus)(_studentId);
      
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

  Future<void> _fetchAttendance() async {
    setState(() {
      _isLoadingAttendance = true;
    });

    try {
      final summary = await (widget.attendanceSummaryOverride ??
          AttendanceService.getAttendanceSummary)(_studentId);
      if (summary['success'] == true) {
        setState(() {
          _attendanceRatio = '${summary['presentSessions']}/${summary['totalSessions']}';
          _attendancePercentage = '${summary['percentage']}%';
        });
      }
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
    }

    if (mounted) {
      setState(() {
        _isLoadingAttendance = false;
      });
    }
  }

  Future<void> _fetchModules() async {
    setState(() {
      _isLoadingModules = true;
    });

    try {
      final modules = await CourseService.getStudentSessions(_studentId);
      if (mounted) {
        setState(() {
          _modules = modules;
          if (modules.isNotEmpty) {
            _courseName = modules.first.technologyName;
          }
          _isLoadingModules = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching modules: $e');
      if (mounted) {
        setState(() {
          _isLoadingModules = false;
        });
      }
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
      backgroundColor: kGrayBg,
      body: Column(
        children: [
          TopBar(
            title: _courseName,
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
                          attendanceRatio: _attendanceRatio,
                          percentage: _attendancePercentage,
                          isLoading: _isLoadingAttendance,
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
                                  border: Border.all(color: kAmber.withOpacity(0.5), width: 1.5),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: _isLoadingModules
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : _modules.isEmpty
                                        ? const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(20.0),
                                              child: Text('No modules found'),
                                            ),
                                          )
                                        : Column(
                                            children: _modules.map((module) {
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
                                                        studentId: _studentId,
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