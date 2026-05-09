import 'dart:convert';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: const SessionFeedbackReport(
        classId: 'class-001',
        totalStudents: 16,
      ),
    );
  }
}

class SessionFeedbackReport extends StatefulWidget {
  final String classId;
  final int totalStudents;

  const SessionFeedbackReport({
    super.key,
    required this.classId,
    this.totalStudents = 0,
  });

  @override
  State<SessionFeedbackReport> createState() => _SessionFeedbackReportState();
}

class _SessionFeedbackReportState extends State<SessionFeedbackReport> {
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:7100',
  );

  bool _isLoading = true;
  String? _error;
  double _overallRating = 0;
  int _feedbackCount = 0;
  List<String> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _loadAiSuggestions();
  }

  Future<void> _loadAiSuggestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('$_apiBaseUrl/ai/process-encrypted-feedback');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'classId': widget.classId}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Backend error ${response.statusCode}: ${response.body}');
      }

      final Map<String, dynamic> payload = Map<String, dynamic>.from(
        jsonDecode(response.body) as Map,
      );

      final dynamic savedRaw = payload['saved'];
      final Map<String, dynamic> saved = savedRaw is Map
          ? Map<String, dynamic>.from(savedRaw)
          : <String, dynamic>{};

      final dynamic analysisRaw = payload['analysis'] ?? saved['analysis'];
      final Map<String, dynamic> analysis = analysisRaw is Map
          ? Map<String, dynamic>.from(analysisRaw)
          : <String, dynamic>{};

      final dynamic suggestionsRaw = analysis['improvementSuggestions'];
      final List<String> suggestions = suggestionsRaw is List
          ? suggestionsRaw
                .whereType<String>()
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : <String>[];

      final dynamic ratingRaw = saved['overallRating'];
      final double rating = double.tryParse((ratingRaw ?? '0').toString()) ?? 0;

      final dynamic countRaw = saved['feedbackCount'];
      final int count = countRaw is num ? countRaw.toInt() : 0;

      if (!mounted) {
        return;
      }

      setState(() {
        _overallRating = rating;
        _feedbackCount = count;
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f7),
      appBar: AppBar(
        backgroundColor: const Color(0xff20a845),
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
        ),
        title: const Text(
          'Session Feedback Report',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadAiSuggestions,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              overallRatingCard(_overallRating, _feedbackCount),
              const SizedBox(height: 20),
              suggestionsCard(
                suggestions: _suggestions,
                isLoading: _isLoading,
                error: _error,
                onRetry: _loadAiSuggestions,
              ),
              const SizedBox(height: 20),
              responseRateCard(_feedbackCount, widget.totalStudents),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff20a845),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _loadAiSuggestions,
                  child: const Text(
                    'Refresh Suggestions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Widget overallRatingCard(double overallRating, int feedbackCount) {
  final double clampedRating = overallRating.clamp(0, 5);
  final int fullStars = clampedRating.floor();
  final bool hasHalf = (clampedRating - fullStars) >= 0.5;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      vertical: 26,
      horizontal: 18,
    ),
    decoration: cardDecoration(),
    child: Column(
      children: [
        const Text(
          'Overall Rating',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              clampedRating.toStringAsFixed(1),
              style: const TextStyle(
                color: Color(0xff14973a),
                fontSize: 58,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 14),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                '/ 5 stars',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            if (index < fullStars) {
              return const Icon(Icons.star, color: Colors.orange, size: 40);
            }
            if (index == fullStars && hasHalf) {
              return const Icon(Icons.star_half, color: Colors.orange, size: 40);
            }
            return const Icon(Icons.star_border, color: Colors.orange, size: 40);
          }),
        ),
        const SizedBox(height: 18),
        Text(
          'Based on $feedbackCount responses',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget suggestionsCard({
  required List<String> suggestions,
  required bool isLoading,
  required String? error,
  required VoidCallback onRetry,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggestions for Improvement',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: const Color(0xfffbfdfc),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (error != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      error,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }

              if (suggestions.isEmpty) {
                return const Text(
                  'No suggestions available yet. Generate AI suggestions from backend.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }

              return Column(
                children: [
                  for (int i = 0; i < suggestions.length; i++) ...[
                    SuggestionPoint(text: suggestions[i]),
                    if (i != suggestions.length - 1) const Divider(height: 34),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

class SuggestionPoint extends StatelessWidget {
  final String text;

  const SuggestionPoint({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 6,
          backgroundColor: Color(0xff14973a),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

Widget responseRateCard(int feedbackCount, int totalStudents) {
  final int safeTotal = totalStudents <= 0 ? feedbackCount : totalStudents;
  final int rate = safeTotal == 0 ? 0 : ((feedbackCount / safeTotal) * 100).round();

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Response Rate',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              height: 95,
              width: 95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffe8f8e9),
                border: Border.all(
                  color: const Color(0xff14973a),
                  width: 6,
                ),
              ),
              child: Center(
                child: Text(
                  '$rate%',
                  style: const TextStyle(
                    color: Color(0xff14973a),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$feedbackCount / $safeTotal',
                    style: const TextStyle(
                      color: Color(0xff14973a),
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'students submitted feedback',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: Colors.grey.shade300,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.10),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
