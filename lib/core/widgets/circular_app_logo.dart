import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

/// Logo de la iglesia mostrado en forma circular.
class CircularAppLogo extends StatelessWidget {
  const CircularAppLogo({
    super.key,
    this.size = 140,
    this.showBorder = true,
  });

  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: showBorder
            ? Border.all(color: AppColors.gold.withValues(alpha: 0.55), width: 2.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(size * 0.07),
          child: Image.asset(
            AppAssets.logoIasdPariachi,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
