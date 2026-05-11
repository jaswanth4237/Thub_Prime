import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ProgressCard extends StatelessWidget {
  final String attendanceRatio;
  final String percentage;
  final bool isLoading;

  const ProgressCard({
    super.key,
    this.attendanceRatio = '200/207',
    this.percentage = '96.6%',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    double pctValue = double.tryParse(percentage.replaceAll('%', '')) ?? 0.0;
    
    return Container(
      color: kGrayBg,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Transform.translate(
        offset: const Offset(0, -50),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kAmber.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            children: [
              // Circular Progress Section
              Transform.translate(
                offset: const Offset(0, -45),
                child: Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          color: kGreen.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          value: pctValue / 100,
                          strokeWidth: 8,
                          backgroundColor: kGreen.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
                        ),
                      ),
                      Text(
                        percentage,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _row('Attendance', attendanceRatio, 200 / 207),
              _row('Assessments', '0/0', 0),
              _row('Activities', '0/0', 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B8A3C),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B8A3C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(1.5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: kAmber,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
