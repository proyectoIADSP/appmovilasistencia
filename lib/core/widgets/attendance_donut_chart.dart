import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AttendanceDonutChart extends StatelessWidget {
  const AttendanceDonutChart({
    super.key,
    required this.present,
    required this.late,
    required this.absent,
    this.size = 200,
  });

  final int present;
  final int late;
  final int absent;
  final double size;

  int get total => present + late + absent;

  @override
  Widget build(BuildContext context) {
    final totalCount = total;
    final pPct = totalCount == 0 ? 0.0 : present / totalCount;
    final lPct = totalCount == 0 ? 0.0 : late / totalCount;
    final aPct = totalCount == 0 ? 0.0 : absent / totalCount;

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DonutPainter(
              present: pPct,
              late: lPct,
              absent: aPct,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    totalCount == 0 ? '0%' : '${(pPct * 100).round()}%',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                  ),
                  Text(
                    'presentes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _LegendRow(
          color: AppColors.present,
          label: 'Presentes',
          value: present,
          percent: pPct,
        ),
        const SizedBox(height: 8),
        _LegendRow(
          color: AppColors.late,
          label: 'Tarde',
          value: late,
          percent: lPct,
        ),
        const SizedBox(height: 8),
        _LegendRow(
          color: AppColors.absent,
          label: 'Ausentes',
          value: absent,
          percent: aPct,
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
  });

  final Color color;
  final String label;
  final int value;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '$value  ·  ${(percent * 100).round()}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.present,
    required this.late,
    required this.absent,
  });

  final double present;
  final double late;
  final double absent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final stroke = radius * 0.28;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    final bg = Paint()
      ..color = AppColors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, 0, math.pi * 2, false, bg);

    var start = -math.pi / 2;
    void drawSlice(double fraction, Color color) {
      if (fraction <= 0) return;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      final sweep = fraction * math.pi * 2;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }

    drawSlice(present, AppColors.present);
    drawSlice(late, AppColors.late);
    drawSlice(absent, AppColors.absent);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.present != present ||
        oldDelegate.late != late ||
        oldDelegate.absent != absent;
  }
}
