import 'package:flutter/material.dart';
import '../../models/satisfaction_enum.dart';
import '../../constants/app_colors.dart';
import '../../responsive/responsive.dart';

import '../mentorScreen.dart';

class ThankYouPage extends StatefulWidget {
  final String topicName;
  final int rating;
  final Satisfaction satisfaction;

  const ThankYouPage({
    super.key,
    required this.topicName,
    required this.rating,
    required this.satisfaction,
  });

  @override
  State<ThankYouPage> createState() =>
      _ThankYouPageState();
}

class _ThankYouPageState
    extends State<ThankYouPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController
  animationController =
      AnimationController(
        vsync: this,
        duration: const Duration(
          milliseconds: 550,
        ),
      )..forward();

  late final Animation<double>
  scaleAnimation =
      CurvedAnimation(
        parent: animationController,
        curve: Curves.elasticOut,
      );

  static const ratingLabels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent',
  ];

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  ({
    String label,
    Color bg,
    Color color,
  }) get satisfactionInfo {
    switch (widget.satisfaction) {
      case Satisfaction.notSatisfied:
        return (
          label: 'Not Satisfied',
          bg: kRedLight,
          color: const Color(
            0xFFA32D2D,
          ),
        );

      case Satisfaction.satisfied:
        return (
          label: 'Satisfied',
          bg: kAmberLight,
          color: const Color(
            0xFF854F0B,
          ),
        );

      case Satisfaction.fullySatisfied:
        return (
          label: 'Fully Satisfied',
          bg: kGreenLight,
          color: kGreenDark,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = satisfactionInfo;

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          buildHeader(),

          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      Responsive.isDesktop(
                            context,
                          )
                          ? 650
                          : double.infinity,
                ),

                child:
                    SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            36,
                          ),

                      child: Column(
                        children: [
                          buildAnimatedStars(),

                          const SizedBox(
                            height: 2,
                          ),

                          const Text(
                            'Thank You!',

                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.w800,
                              color: Color(
                                0xFF111111,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            'Your feedback for ${widget.topicName} has been recorded. '
                            'Your response helps improve teaching quality for everyone.',

                            textAlign:
                                TextAlign.center,

                            style:
                                const TextStyle(
                                  fontSize: 13,
                                  color: Color(
                                    0xFF666666,
                                  ),
                                  height: 1.6,
                                ),
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          buildSummaryCard(
                            info,
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          buildBackButton(),

                          const SizedBox(
                            height: 10,
                          ),

                          buildDoneButton(),
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

  Widget buildHeader() {
    return SizedBox(
      height: 250,

      child: Stack(
        clipBehavior: Clip.none,

        children: [
          Positioned.fill(
            child: ClipPath(
              clipper:
                  _ThankYouWaveClipper(),

              child: Container(
                color: kGreen,

                child: SafeArea(
                  bottom: false,

                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                          16,
                          14,
                          16,
                          70,
                        ),

                    child: Padding(
                      padding: const EdgeInsets.only(top:16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                      
                            children: const [
                              Text(
                                'Feedback Submitted',
                      
                                style: TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // SUCCESS ICON
          Positioned(
            top: 136,
            left: 0,
            right: 0,

            child: Center(
              child:
                  buildAnimatedSuccess(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnimatedSuccess() {
    return ScaleTransition(
      scale: scaleAnimation,

      child: Container(
        width:
            Responsive.isDesktop(
                  context,
                )
                ? 120
                : 96,

        height:
            Responsive.isDesktop(
                  context,
                )
                ? 120
                : 96,

        decoration: BoxDecoration(
          color: kGreenLight,
          shape: BoxShape.circle,

          border: Border.all(
            color: kGreen,
            width: 3,
          ),
        ),

        child: Icon(
          Icons
              .check_circle_outline_rounded,

          color: kGreen,

          size:
              Responsive.isDesktop(
                    context,
                  )
                  ? 65
                  : 50,
        ),
      ),
    );
  }

  Widget buildAnimatedStars() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: List.generate(
        5,
        (index) =>
            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0,
                end: 1,
              ),

              duration: Duration(
                milliseconds:
                    300 + index * 80,
              ),

              builder:
                  (_, value, child) {
                    return Opacity(
                      opacity: value,

                      child:
                          Transform.translate(
                            offset: Offset(
                              0,
                              8 * (1 - value),
                            ),

                            child: child,
                          ),
                    );
                  },

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
                          ? 38
                          : 30,

                  color:
                      (index + 1) <=
                              widget.rating
                          ? kAmber
                          : kBorder,
                ),
              ),
            ),
      ),
    );
  }

  Widget buildSummaryCard(
    dynamic info,
  ) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: kGrayBg,

        borderRadius:
            BorderRadius.circular(
              14,
            ),
      ),

      child: Column(
        children: [
          buildSummaryRow(
            'Session topic',
            widget.topicName,
          ),

          const Divider(
            height: 12,
            color: Color(0xFFEBEBEB),
          ),

          buildSummaryRow(
            'Rating',
            '${ratingLabels[widget.rating]} (${widget.rating}/5)',
          ),

          const Divider(
            height: 12,
            color: Color(0xFFEBEBEB),
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [
              const Text(
                'Satisfaction',

                style: TextStyle(
                  fontSize: 13,
                  color: Color(
                    0xFF888888,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),

                decoration: BoxDecoration(
                  color: info.bg,

                  borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                ),

                child: Text(
                  info.label,

                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                    color: info.color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSummaryRow(
    String title,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,

          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF888888),
          ),
        ),

        Flexible(
          child: Text(
            value,

            textAlign: TextAlign.right,

            style: const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
              color: kGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBackButton() {
    return SizedBox(
      width: double.infinity,

      height:
          Responsive.isDesktop(
                context,
              )
              ? 60
              : 52,

      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.popUntil(
            context,
            (route) => route.isFirst,
          );
        },

        style:
            ElevatedButton.styleFrom(
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
          Icons.home_outlined,
          size: 20,
        ),

        label: const Text(
          'Back to Course',

          style: TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget buildDoneButton() {
    return SizedBox(
      width: double.infinity,

      height:
          Responsive.isDesktop(
                context,
              )
              ? 60
              : 52,

      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      const MentorScreen(
                        classId:
                            'class-001',
                      ),
            ),
          );
        },

        style:
            OutlinedButton.styleFrom(
              foregroundColor:
                  kGreen,

              side: const BorderSide(
                color: kGreen,
                width: 2.5,
              ),

              shape:
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                  ),
            ),

        icon: const Icon(
          Icons.check_rounded,
          size: 20,
        ),

        label: const Text(
          'Done',

          style: TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ThankYouWaveClipper
    extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    path.lineTo(
      0,
      size.height - 95,
    );

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
  bool shouldReclip(
    covariant CustomClipper<Path>
    oldClipper,
  ) {
    return false;
  }
}