import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/course/course_detail_page.dart';
import 'package:frontend/screens/blockScreen.dart';

// A simple mock for the HTTP calls using HttpOverrides
class MockHttpOverrides extends HttpOverrides {
  final String mockResponse;
  final int statusCode;

  MockHttpOverrides({required this.mockResponse, this.statusCode = 200});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient(mockResponse, statusCode);
  }
}

class MockHttpClient implements HttpClient {
  final String mockResponse;
  final int statusCode;
  MockHttpClient(this.mockResponse, this.statusCode);

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => MockHttpClientRequest(mockResponse, statusCode);
  
  @override
  Future<HttpClientRequest> postUrl(Uri url) async => MockHttpClientRequest(mockResponse, statusCode);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientRequest implements HttpClientRequest {
  final String mockResponse;
  final int statusCode;
  MockHttpClientRequest(this.mockResponse, this.statusCode);

  @override
  HttpHeaders get headers => MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse(mockResponse, statusCode);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientResponse implements HttpClientResponse {
  final String mockResponse;
  final int statusCode;
  MockHttpClientResponse(this.mockResponse, this.statusCode);

  @override
  int get statusCode => this.statusCode;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream.fromIterable([utf8.encode(mockResponse)]).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  testWidgets('CourseDetailPage redirects to BlockScreen when blocked', (WidgetTester tester) async {
    // 1. Set up the "blocked" mock response
    final mockData = jsonEncode({
      'success': true,
      'isBlocked': true,
      'classId': 'C123',
      'message': 'Pending Feedback Test'
    });

    HttpOverrides.runZoned(() async {
      await tester.pumpWidget(const MaterialApp(home: CourseDetailPage()));
      
      // Initial state is loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for the async check to complete and navigation to happen
      await tester.pumpAndSettle();
      
      // Should now be on BlockScreen
      expect(find.byType(BlockScreen), findsOneWidget);
      expect(find.text('Access Restricted'), findsOneWidget);
      expect(find.text('Pending Feedback Test'), findsOneWidget);
    }, createHttpClient: (context) => MockHttpClient(mockData, 200));
  });

  testWidgets('CourseDetailPage loads normally when not blocked', (WidgetTester tester) async {
    // 1. Set up the "NOT blocked" mock response
    final mockData = jsonEncode({
      'success': true,
      'isBlocked': false
    });

    HttpOverrides.runZoned(() async {
      await tester.pumpWidget(const MaterialApp(home: CourseDetailPage()));
      
      await tester.pumpAndSettle();
      
      // Should show the normal dashboard content
      expect(find.byType(BlockScreen), findsNothing);
      expect(find.text('Google Flutter'), findsOneWidget);
      expect(find.text('Modules'), findsOneWidget);
    }, createHttpClient: (context) => MockHttpClient(mockData, 200));
  });
}
