import 'package:flutter/material.dart';

import '../../features/attendance/domain/entities/attendance.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AttendanceStatusBadge extends StatelessWidget {
  const AttendanceStatusBadge({super.key, this.status});

  final AttendanceStatus? status;

  @override
  Widget build(BuildContext context) {
    if (status == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.outline.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'Sin marcar',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );
    }

    final (bg, fg) = switch (status!) {
      AttendanceStatus.present => (AppColors.presentBg, AppColors.present),
      AttendanceStatus.late => (AppColors.lateBg, AppColors.late),
      AttendanceStatus.absent => (AppColors.absentBg, AppColors.absent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status!.labelEs,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class AttendanceStatusSelector extends StatelessWidget {
  const AttendanceStatusSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AttendanceStatus? value;
  final ValueChanged<AttendanceStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AttendanceStatus.values.map((status) {
        final selected = status == value;
        final (bg, fg, icon) = switch (status) {
          AttendanceStatus.present => (
              AppColors.presentBg,
              AppColors.present,
              Icons.check_circle_rounded,
            ),
          AttendanceStatus.late => (
              AppColors.lateBg,
              AppColors.late,
              Icons.schedule_rounded,
            ),
          AttendanceStatus.absent => (
              AppColors.absentBg,
              AppColors.absent,
              Icons.cancel_rounded,
            ),
        };

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: status == AttendanceStatus.absent ? 0 : 6,
            ),
            child: Material(
              color: selected ? fg : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: InkWell(
                onTap: () => onChanged(status),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: selected ? fg : AppColors.outline,
                    ),
                    color: selected ? null : bg.withValues(alpha: 0.35),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: selected ? Colors.white : fg,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.labelEs,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : fg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
    this.onTap,
    this.selected = false,
  });

  final String label;
  final int value;
  final Color color;
  final Color background;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? color : background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: selected ? color : color.withValues(alpha: 0.25),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    color: selected ? Colors.white : color,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.95)
                        : color.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
