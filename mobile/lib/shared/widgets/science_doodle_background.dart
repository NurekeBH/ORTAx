import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

class ScienceDoodleBackground extends StatelessWidget {
  final double? opacity;
  const ScienceDoodleBackground({super.key, this.opacity});

  static const _icons = <IconData>[
    Icons.science_outlined,
    Icons.bubble_chart_outlined,
    Icons.functions,
    Icons.calculate_outlined,
    Icons.psychology_outlined,
    Icons.biotech_outlined,
    Icons.spa_outlined,
    Icons.lightbulb_outline,
    Icons.public_outlined,
    Icons.architecture_outlined,
    Icons.scatter_plot_outlined,
    Icons.school_outlined,
    Icons.menu_book_outlined,
    Icons.rocket_launch_outlined,
    Icons.auto_awesome_outlined,
    Icons.hub_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark
        ? Colors.white.withValues(alpha: opacity ?? 0.06)
        : AppColors.primary.withValues(alpha: opacity ?? 0.05);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        if (w <= 0 || h <= 0) return const SizedBox.shrink();

        final rand = Random(42);
        final tiles = <Widget>[];
        const cols = 4;
        final rows = (h / (w / cols)).ceil() + 1;

        final cellW = w / cols;
        final cellH = w / cols;

        for (var r = 0; r < rows; r++) {
          for (var c = 0; c < cols; c++) {
            final idx = (r * cols + c * 3) % _icons.length;
            final icon = _icons[idx];
            final jitterX = (rand.nextDouble() - 0.5) * cellW * 0.5;
            final jitterY = (rand.nextDouble() - 0.5) * cellH * 0.5;
            final iconSize = 32 + rand.nextDouble() * 28;
            final angle = (rand.nextDouble() - 0.5) * 0.7;
            final left = c * cellW + jitterX + (cellW - iconSize) / 2;
            final top = r * cellH + jitterY + (cellH - iconSize) / 2;
            tiles.add(Positioned(
              left: left,
              top: top,
              child: Transform.rotate(
                angle: angle,
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
            ));
          }
        }
        return ClipRect(
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(children: tiles),
          ),
        );
      },
    );
  }
}
