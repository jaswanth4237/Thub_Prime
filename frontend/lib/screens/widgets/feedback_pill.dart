import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class FeedbackPill extends StatelessWidget {
  final bool enabled;
  final bool done;
  final VoidCallback? onTap;

  const FeedbackPill({
    super.key,
    required this.enabled,
    required this.done,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (done) {
      return _pill(
        'Completed',
        bg: kGreenLight,
        textColor: kGreen,
        border: const BorderSide(color: kGreen, width: 2),
      );
    }

    if (enabled) {
      return _pill(
        'Feedback',
        bg: kGreen,
        textColor: Colors.white,
        border: BorderSide.none,
        onTap: onTap,
      );
    }

    return _pill(
      'Feedback',
      bg: kGrayBg,
      textColor: kDimText,
      border: const BorderSide(color: kBorder),
    );
  }

  Widget _pill(
    String text, {
    required Color bg,
    required Color textColor,
    required BorderSide border,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.fromBorderSide(border),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}