import 'package:flutter/material.dart';

import '../constants/app_assets.dart';

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
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: showBorder
            ? Border.all(color: primary.withValues(alpha: 0.25), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(size * 0.06),
          child: Image.asset(
            AppAssets.logoIasdPariachi,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
