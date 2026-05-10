import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../responsive/responsive.dart';
import '../../models/satisfaction_enum.dart';
import '../../services/feedback_service.dart';
import '../widgets/satisfaction_button.dart';
import 'thank_you_page.dart';

class FeedbackFormPage extends StatefulWidget {
  final String courseName;
  final String topicName;
  final String classId;
  final String studentId;
  final String mentorId;

  const FeedbackFormPage({
    super.key,
    required this.courseName,
    required this.topicName,
    required this.classId,
    required this.studentId,
    required this.mentorId,
  });

  @override
  State<FeedbackFormPage> createState() =>
      _FeedbackFormPageState();
}

class _FeedbackFormPageState
    extends State<FeedbackFormPage> {
  int rating = 0;
  Satisfaction? satisfaction;
  final TextEditingController commentController = TextEditingController();
  String commentError = '';
  String satisfactionError = '';
  int wordCount = 0;
  bool _isSubmitting = false;

  static const List<String> ratingLabels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent',
  ];

  static const List<Color> ratingColors = [
    Colors.transparent,
    kRed,
    kRed,
    kAmber,
    kGreen,
    kGreen,
  ];

  @override
  void initState() {
    super.initState();

    commentController.addListener(onCommentChanged);
  }

  @override
  void dispose() {
    commentController.removeListener(
      onCommentChanged,
    );

    commentController.dispose();

    super.dispose();
  }

  void onCommentChanged() {
    setState(() {
      wordCount = countWords(
        commentController.text,
      );

      commentError = '';
    });
  }

  int countWords(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  Color get wordCountColor {
    if (wordCount == 0) {
      return const Color(0xFF999999);
    }

    return (wordCount >= 5 &&
            wordCount <= 500)
        ? kGreen
        : kRed;
  }

  String get wordCountText {
    if (wordCount == 0) {
      return 'Min 5 words · Max 500 words';
    }

    if (wordCount < 5) {
      return '$wordCount / 500 words — need at least 5';
    }

    return '$wordCount / 500 words';
  }

  Future<void> submitFeedback() async {
    setState(() {
      commentError = '';
      satisfactionError = '';
    });

    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please rate the session'),
          backgroundColor: kRed,
        ),
      );
      return;
    }

    if (satisfaction == null) {
      setState(() {
        satisfactionError = 'Please select satisfaction level';
      });
      return;
    }

    final words = countWords(commentController.text);

    if (words < 5) {
      setState(() {
        commentError = 'Please write at least 5 words';
      });
      return;
    }

    if (words > 500) {
      setState(() {
        commentError = 'Maximum 500 words allowed';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FeedbackService.submitFeedback(
        classId: widget.classId,
        studentId: widget.studentId,
        mentorId: widget.mentorId,
        rating: rating,
        comments: commentController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ThankYouPage(
            topicName: widget.topicName,
            rating: rating,
            satisfaction: satisfaction!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: kRed,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: kGrayBg,
      resizeToAvoidBottomInset: true,

      body: Column(
        children: [
          buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1000 : double.infinity,
                  ),
                  child: isDesktop ? buildDesktopLayout() : buildMobileLayout(),
                ),
              ),
            ),
          ),

          buildSubmitBar(),
        ],
      ),
    );
  }

  Widget buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 24),
                buildSatisfactionCard(),

                const SizedBox(height: 14),

                buildCommentCard(),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: buildCommentCard(),
          ),
        ],
      ),
    );
  }

  Widget buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          buildSatisfactionCard(),

          const SizedBox(height: 14),

          buildCommentCard(),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return SizedBox(
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: _HeaderWaveClipper(),
              child: Container(
                color: kGreen,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 58),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.22),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),

                            const Spacer(),

                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          widget.courseName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 150,
            left: 14,
            right: 14,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFFFD700),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: buildStarCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStarCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Rate this session',

            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            "How was today's class?",

            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: List.generate(
              5,
              (index) {
                final value = index + 1;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      rating = value;
                    });
                  },

                  child: AnimatedScale(
                    scale:
                        rating == value
                            ? 1.25
                            : 1.0,

                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),

                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 3,
                      ),

                      child: Icon(
                        Icons.star_rounded,

                        size:
                            Responsive.isDesktop(
                                  context,
                                )
                                ? 56
                                : 42,

                        color:
                            value <= rating
                                ? kAmber
                                : kBorder,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Text(
            rating == 0
                ? 'Tap a star to rate'
                : ratingLabels[rating],

            style: TextStyle(
              fontSize: 13,

              color:
                  rating == 0
                      ? const Color(
                        0xFFBBBBBB,
                      )
                      : ratingColors[rating],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSatisfactionCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 255, 217, 0),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Overall satisfaction',

            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: SatisfactionButton(
                  icon:
                      Icons
                          .sentiment_dissatisfied_outlined,

                  label:
                      'Not\nSatisfied',

                  value:
                      Satisfaction
                          .notSatisfied,

                  selected:
                      satisfaction,

                  selBg: kRedLight,
                  selBorder: kRed,
                  selIconColor: kRed,

                  selTextColor:
                      const Color(
                    0xFFA32D2D,
                  ),

                  onTap: () {
                    setState(() {
                      satisfaction =
                          Satisfaction
                              .notSatisfied;

                      satisfactionError =
                          '';
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: SatisfactionButton(
                  icon:
                      Icons
                          .sentiment_satisfied_outlined,

                  label:
                      'Satisfied',

                  value:
                      Satisfaction
                          .satisfied,

                  selected:
                      satisfaction,

                  selBg:
                      kAmberLight,

                  selBorder:
                      kAmber,

                  selIconColor:
                      kAmber,

                  selTextColor:
                      const Color(
                    0xFF854F0B,
                  ),

                  onTap: () {
                    setState(() {
                      satisfaction =
                          Satisfaction
                              .satisfied;

                      satisfactionError =
                          '';
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: SatisfactionButton(
                  icon:
                      Icons
                          .sentiment_very_satisfied_outlined,

                  label:
                      'Fully\nSatisfied',

                  value:
                      Satisfaction
                          .fullySatisfied,

                  selected:
                      satisfaction,

                  selBg:
                      kGreenLight,

                  selBorder:
                      kGreen,

                  selIconColor:
                      kGreen,

                  selTextColor:
                      kGreenDark,

                  onTap: () {
                    setState(() {
                      satisfaction =
                          Satisfaction
                              .fullySatisfied;

                      satisfactionError =
                          '';
                    });
                  },
                ),
              ),
            ],
          ),

          if (satisfactionError
              .isNotEmpty) ...[
            const SizedBox(height: 8),

            Text(
              satisfactionError,

              style: const TextStyle(
                fontSize: 11,
                color: kRed,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildCommentCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 251, 213, 0),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Text(
                'Comments',

                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                ),
              ),

              const SizedBox(width: 4),

              const Text(
                '*',

                style: TextStyle(
                  color: kRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          Text(
            wordCountText,

            style: TextStyle(
              fontSize: 11,
              color: wordCountColor,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller:
                commentController,

            maxLines: 3,

            decoration: InputDecoration(
              hintText:
                  'Write your feedback (min 5 words)…',

              hintStyle:
                  const TextStyle(
                fontSize: 13,
                color: Color(
                  0xFFAAAAAA,
                ),
              ),

              contentPadding:
                  const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),

                borderSide:
                    const BorderSide(
                  color: kBorder,
                  width: 2,
                ),
              ),

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),

                borderSide:
                    const BorderSide(
                  color: kBorder,
                  width: 2,
                ),
              ),

              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),

                borderSide:
                    const BorderSide(
                  color: kGreen,
                  width: 2,
                ),
              ),
            ),
          ),

          if (commentError.isNotEmpty) ...[
            const SizedBox(height: 2),

            Text(
              commentError,

              style: const TextStyle(
                fontSize: 11,
                color: kRed,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildSubmitBar() {
    return Container(
      color: kGrayBg,

      padding:
          const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        24,
      ),

      child: SafeArea(
        top: false,

        child: SizedBox(
          width: double.infinity,

          height:
              Responsive.isDesktop(
                    context,
                  )
                  ? 60
                  : 52,

          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : submitFeedback,

            style: ElevatedButton.styleFrom(
              backgroundColor:
                  kGreen,

              foregroundColor:
                  Colors.white,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),

              elevation: 0,
            ),

            icon: const Icon(
              Icons.send_rounded,
              size: 18,
            ),

            label: const Text(
              'Submit Feedback',

              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Wave clipper moved outside the state class
class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 84);

    final firstControlPoint = Offset(size.width * 0.22, size.height - 10);
    final firstEndPoint = Offset(size.width * 0.48, size.height - 66);

    final secondControlPoint = Offset(size.width * 0.78, size.height - 120);
    final secondEndPoint = Offset(size.width, size.height - 88);

    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}