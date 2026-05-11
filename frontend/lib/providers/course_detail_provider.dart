import 'package:flutter/foundation.dart';

import '../models/course_module.dart';
import '../services/attendance_service.dart';
import '../services/course_service.dart';
import '../services/feedback_service.dart';

class CourseDetailProvider extends ChangeNotifier {
  bool _isCheckingStatus = true;
  bool _isLoadingAttendance = true;
  bool _isLoadingModules = true;

  String _attendanceRatio = '0/0';
  String _attendancePercentage = '0%';
  String _courseName = 'Google Flutter';

  final String _studentId = '66ed42436aebf032ad4404a8';

  List<CourseModule> _modules = [];

  bool get isCheckingStatus => _isCheckingStatus;
  bool get isLoadingAttendance => _isLoadingAttendance;
  bool get isLoadingModules => _isLoadingModules;

  String get attendanceRatio => _attendanceRatio;
  String get attendancePercentage => _attendancePercentage;
  String get courseName => _courseName;
  String get studentId => _studentId;

  List<CourseModule> get modules => _modules;

  Future<Map<String, dynamic>> checkBlockedStatus({
    Future<Map<String, dynamic>> Function(String studentId)? overrideFn,
  }) async {
    _isCheckingStatus = true;
    notifyListeners();

    try {
      return await (overrideFn ?? FeedbackService.checkBlockedStatus)(_studentId);
    } catch (e) {
      debugPrint('Error checking blocked status: $e');
      return {'success': false, 'isBlocked': false};
    } finally {
      _isCheckingStatus = false;
      notifyListeners();
    }
  }

  Future<void> fetchAttendance({
    Future<Map<String, dynamic>> Function(String studentId)? overrideFn,
  }) async {
    _isLoadingAttendance = true;
    notifyListeners();

    try {
      final summary = await (overrideFn ?? AttendanceService.getAttendanceSummary)(_studentId);
      if (summary['success'] == true) {
        _attendanceRatio = '${summary['presentSessions']}/${summary['totalSessions']}';
        _attendancePercentage = '${summary['percentage']}%';
      }
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
    } finally {
      _isLoadingAttendance = false;
      notifyListeners();
    }
  }

  Future<void> fetchModules() async {
    _isLoadingModules = true;
    notifyListeners();

    try {
      final loadedModules = await CourseService.getStudentSessions(_studentId);
      _modules = loadedModules;
      if (loadedModules.isNotEmpty) {
        _courseName = loadedModules.first.technologyName;
      }
    } catch (e) {
      debugPrint('Error fetching modules: $e');
    } finally {
      _isLoadingModules = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll({
    Future<Map<String, dynamic>> Function(String studentId)? checkBlockedStatusOverride,
    Future<Map<String, dynamic>> Function(String studentId)? attendanceSummaryOverride,
  }) async {
    final status = await checkBlockedStatus(overrideFn: checkBlockedStatusOverride);

    if (status['success'] == true && status['isBlocked'] == true) {
      return;
    }

    await Future.wait([
      fetchAttendance(overrideFn: attendanceSummaryOverride),
      fetchModules(),
    ]);
  }
}
