import 'package:flutter/material.dart';
import '../../models/satisfaction_enum.dart';
import '../../constants/app_colors.dart';
import '../feedback/feedback_form_page.dart';

class SatisfactionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Satisfaction value;
  final Satisfaction? selected;

  final Color selBg;
  final Color selBorder;
  final Color selIconColor;
  final Color selTextColor;

  final VoidCallback onTap;

  const SatisfactionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.selBg,
    required this.selBorder,
    required this.selIconColor,
    required this.selTextColor,
    required this.onTap,
  });

  bool get isSelected => selected == value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? selBg
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? selBorder
                : kBorder,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? selIconColor
                  : const Color(0xFFCCCCCC),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? selTextColor
                    : const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}