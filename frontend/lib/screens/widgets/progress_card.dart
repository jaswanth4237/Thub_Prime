import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ProgressCard extends StatelessWidget {
  final String attendanceRatio;
  final String percentage;
  final bool isLoading;

  const ProgressCard({
    super.key,
    this.attendanceRatio = '0/0',
    this.percentage = '0%',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kGrayBg,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Transform.translate(
        offset: const Offset(0, -28),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kAmber, width: 2),
          ),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Column(
            children: [
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: kGreenLight,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(
                        color: kGreen,
                        width: 3,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kGreen))
                    : Text(
                        percentage,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: kGreen,
                        ),
                      ),
                ),
              ),
              _row('Attendance', attendanceRatio),
              const Divider(color: kAmber, thickness: 1.5),
              _row('Assessments', '0/0'),
              const Divider(color: kAmber, thickness: 1.5),
              _row('Activities', '0/0'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kGreen,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kGreen,
            ),
          ),
        ],
      ),
    );
  }
}