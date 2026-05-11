import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_colors.dart';

class MentorScreen extends StatefulWidget {
  final String classId;
  final int totalStudents;

  const MentorScreen({
    super.key,
    required this.classId,
    this.totalStudents = 0,
  });

  @override
  State<MentorScreen> createState() =>
      _MentorScreenState();
}

class _MentorScreenState
    extends State<MentorScreen> {
  final String _apiBaseUrl = dotenv.get('API_BASE_URL', fallback: 'https://backend-thubprime.onrender.com');

  bool _isLoading = true;

  String? _error;

  double _overallRating = 0;

  int _feedbackCount = 0;
  int _totalStudents = 0;

  List<String> _suggestions =
      const [];

  @override
  void initState() {
    super.initState();

    _loadAiSuggestions();
  }

  Future<void>
  _loadAiSuggestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
        '$_apiBaseUrl/ai/process-encrypted-feedback',
      );

      final response = await http.post(
        uri,

        headers: {
          'Content-Type': 'application/json',
          'x-user-role': 'mentor', // In a real app, this comes from AuthService.currentUser
        },

        body: jsonEncode({
          'classId': widget.classId,
        }),
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Backend error ${response.statusCode}: ${response.body}',
        );
      }

      final dynamic decoded =
          jsonDecode(response.body);

      Map<String, dynamic> analysis =
          {};

      Map<String, dynamic> saved = {};

      if (decoded is Map &&
          (decoded.containsKey(
                'mentorPerformance',
              ) ||
              decoded.containsKey(
                'improvementSuggestions',
              ))) {
        analysis =
            Map<String, dynamic>.from(
              decoded,
            );
      } else if (decoded is Map &&
          decoded.containsKey(
            'analysis',
          )) {
        final dynamic analysisRaw =
            decoded['analysis'];

        if (analysisRaw is Map) {
          analysis =
              Map<String, dynamic>.from(
                analysisRaw,
              );
        }

        final dynamic savedRaw =
            decoded['saved'];

        if (savedRaw is Map) {
          saved =
              Map<String, dynamic>.from(
                savedRaw,
              );
        }
      }

      final dynamic suggestionsRaw =
          analysis[
              'improvementSuggestions'];

      final List<String> suggestions =
          suggestionsRaw is List
              ? suggestionsRaw
                  .whereType<String>()
                  .map(
                    (e) => e.trim(),
                  )
                  .where(
                    (e) =>
                        e.isNotEmpty,
                  )
                  .toList()
              : <String>[];

      final dynamic ratingRaw =
          analysis['overallRating'] ??
              saved['overallRating'];

      final double rating =
          double.tryParse(
                (ratingRaw ?? '0')
                    .toString(),
              ) ??
              0;

      final dynamic countRaw =
          saved['feedbackCount'] ?? decoded['feedbackCount'] ?? 0;

      final int count =
          countRaw is num
              ? countRaw.toInt()
              : int.tryParse(
                    '$countRaw',
                  ) ??
                  0;

      final dynamic totalStudentsRaw = decoded['totalStudents'];
      final int totalStudents = totalStudentsRaw is num ? totalStudentsRaw.toInt() : 0;

      if (!mounted) {
        return;
      }

      setState(() {
        _overallRating = rating;
        _feedbackCount = count;
        _totalStudents = totalStudents > 0 ? totalStudents : widget.totalStudents;
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
      backgroundColor:
          const Color(0xfff6f7f7),

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. GREEN WAVY HEADER BACKGROUND
              ClipPath(
                clipper: MentorWaveClipper(),
                child: Container(
                  height: 260,
                  color: kGreen,
                ),
              ),

              // 2. APP BAR CONTENTS
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Session Feedback Report',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
                ),
              ),

              // 3. FLOATING RATING CARD
              Positioned(
                top: 140, // Positioned to overlap the wave
                left: 20,
                right: 20,
                child: overallRatingCard(
                  _overallRating,
                  _feedbackCount,
                ),
              ),
            ],
          ),

          // GAP FOR THE FLOATING CARD'S BOTTOM HALF
          const SizedBox(height: 110),

          // 4. REST OF THE CONTENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                suggestionsCard(
                  suggestions: _suggestions,
                  isLoading: _isLoading,
                  error: _error,
                  onRetry: _loadAiSuggestions,
                ),
                const SizedBox(height: 20),
                responseRateCard(
                  _feedbackCount,
                  _totalStudents,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget overallRatingCard(
  double overallRating,
  int feedbackCount,
) {
  final double clampedRating =
      overallRating.clamp(0, 5);

  final int fullStars =
      clampedRating.floor();

  final bool hasHalf =
      (clampedRating - fullStars) >=
          0.5;

  return Container(
    width: double.infinity,

    padding:
        const EdgeInsets.symmetric(
      vertical: 18,
      horizontal: 16,
    ),

    decoration: cardDecoration(),

    child: Column(
      children: [
        const Text(
          'Overall Rating',

          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          crossAxisAlignment:
              CrossAxisAlignment.end,

          children: [
            Text(
              clampedRating
                  .toStringAsFixed(1),

              style: const TextStyle(
                color: Color(
                  0xff14973a,
                ),

                fontSize: 42,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(width: 8),

            const Padding(
              padding:
                  EdgeInsets.only(
                bottom: 8,
              ),

              child: Text(
                '/ 5 stars',

                style: TextStyle(
                  color: Colors.grey,

                  fontSize: 18,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: List.generate(
            5,
            (index) {
              if (index <
                  fullStars) {
                return const Icon(
                  Icons.star,

                  color:
                      Colors.orange,

                  size: 28,
                );
              }

              if (index ==
                      fullStars &&
                  hasHalf) {
                return const Icon(
                  Icons.star_half,

                  color:
                      Colors.orange,

                  size: 28,
                );
              }

              return const Icon(
                Icons.star_border,

                color:
                    Colors.orange,

                size: 28,
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Based on $feedbackCount responses',

          style: const TextStyle(
            color: Colors.grey,

            fontSize: 14,

            fontWeight:
                FontWeight.w600,
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

    padding:
        const EdgeInsets.all(18),

    decoration: cardDecoration(),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'Suggestions for Improvement',

          style: TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 22),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),

          decoration: BoxDecoration(
            color:
                const Color(0xfffbfdfc),

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            border: Border.all(
              color:
                  Colors.grey.shade300,
            ),
          ),

          child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              if (error != null) {
                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      error,

                      style:
                          const TextStyle(
                        color:
                            Colors.red,

                        fontSize: 14,

                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    ElevatedButton(
                      onPressed:
                          onRetry,

                      child: const Text(
                        'Retry',
                      ),
                    ),
                  ],
                );
              }

              if (suggestions.isEmpty) {
                return const Text(
                  'No suggestions available yet.',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w500,
                  ),
                );
              }

              return Column(
                children: [
                  for (int i = 0;
                      i <
                          suggestions
                              .length;
                      i++) ...[
                    SuggestionPoint(
                      text:
                          suggestions[i],
                    ),

                    if (i !=
                        suggestions
                                .length -
                            1)
                      const Divider(
                        height: 34,
                      ),
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

class SuggestionPoint
    extends StatelessWidget {
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
          backgroundColor:
              Color(0xff14973a),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Text(
            text,

            style: const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

Widget responseRateCard(
  int feedbackCount,
  int totalStudents,
) {
  final int safeTotal =
      totalStudents <= 0
          ? feedbackCount
          : totalStudents;

  final int rate =
      safeTotal == 0
          ? 0
          : ((feedbackCount /
                      safeTotal) *
                  100)
              .round();

  Color rateColor = kGreen;
  if (rate < 30) {
    rateColor = kRed;
  } else if (rate < 70) {
    rateColor = kAmber;
  }

  return Container(
    width: double.infinity,

    padding:
        const EdgeInsets.all(22),

    decoration: cardDecoration(),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'Response Rate',

          style: TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Text(
                    '$rate%',

                    style:
                        TextStyle(
                      fontSize: 32,

                      fontWeight:
                          FontWeight
                              .bold,

                      color: rateColor,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    '$feedbackCount / $safeTotal students',

                    style:
                        const TextStyle(
                      fontSize: 14,

                      color:
                          Colors.grey,

                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: 120,
              height: 120,

              child: Stack(
                alignment:
                    Alignment.center,

                children: [
                  SizedBox(
                    width: 120,
                    height: 120,

                    child:
                        CircularProgressIndicator(
                      value:
                          rate / 100,

                      strokeWidth:
                          12,

                      backgroundColor:
                          Colors.grey
                              .shade200,

                      valueColor:
                          AlwaysStoppedAnimation<
                            Color
                          >(
                        rateColor,
                      ),
                    ),
                  ),

                  Text(
                    '$rate%',

                    style:
                        TextStyle(
                      fontSize: 24,

                      fontWeight:
                          FontWeight
                              .bold,

                      color: rateColor,
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

    borderRadius:
        BorderRadius.circular(18),

    boxShadow: [
      BoxShadow(
        color: Colors.grey
            .withOpacity(0.1),

        blurRadius: 8,

        offset:
            const Offset(0, 2),
      ),
    ],
  );
}

class MentorWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 95);

    path.quadraticBezierTo(
      size.width * 0.22,
      size.height - 10,
      size.width * 0.5,
      size.height - 70,
    );

    path.quadraticBezierTo(
      size.width * 0.82,
      size.height - 135,
      size.width,
      size.height - 92,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}