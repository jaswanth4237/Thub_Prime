import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/blockScreen.dart';
import 'package:frontend/screens/course/course_detail_page.dart';

void main() {
  testWidgets('CourseDetailPage redirects to BlockScreen when blocked', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseDetailPage(
          checkBlockedStatusOverride: (studentId) async => {
            'success': true,
            'isBlocked': true,
            'classId': 'C123',
            'message': 'Pending Feedback Test',
          },
          attendanceSummaryOverride: (studentId) async => {
            'success': true,
            'presentSessions': 0,
            'totalSessions': 0,
            'percentage': 0,
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(BlockScreen), findsOneWidget);
    expect(find.text('Access Restricted'), findsOneWidget);
    expect(find.text('Pending Feedback Test'), findsOneWidget);
  });

  testWidgets('CourseDetailPage loads normally when not blocked', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseDetailPage(
          checkBlockedStatusOverride: (studentId) async => {
            'success': true,
            'isBlocked': false,
          },
          attendanceSummaryOverride: (studentId) async => {
            'success': true,
            'presentSessions': 8,
            'totalSessions': 10,
            'percentage': 80,
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(BlockScreen), findsNothing);
    expect(find.text('Google Flutter'), findsOneWidget);
    expect(find.text('Modules'), findsOneWidget);
  });
}
