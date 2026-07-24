import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models.dart';

/// A small guard buddy avatar: hard hat, face, and a body in the buddy's
/// signature color, with their tool badge in the corner.
class MiniBuddyAvatar extends StatelessWidget {
  const MiniBuddyAvatar({super.key, required this.buddy, this.size = 44});

  final MiniBuddy buddy;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _MiniBuddyPainter(color: buddy.color),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Text(buddy.tool, style: TextStyle(fontSize: size * 0.34)),
          ),
        ],
      ),
    );
  }
}

class _MiniBuddyPainter extends CustomPainter {
  _MiniBuddyPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 60;
    canvas.scale(s);
    final fill = Paint()..style = PaintingStyle.fill;

    // Body.
    fill.color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(17, 34, 26, 22), const Radius.circular(8)),
      fill,
    );

    // Head.
    fill.color = const Color(0xFFFFD9A0);
    canvas.drawCircle(const Offset(30, 24), 14, fill);

    // Hard hat, tinted a touch darker than the body.
    final hat = HSLColor.fromColor(color);
    fill.color =
        hat.withLightness((hat.lightness - 0.08).clamp(0.0, 1.0)).toColor();
    final hatPath = Path()
      ..addArc(
          Rect.fromCenter(
              center: const Offset(30, 20), width: 30, height: 24),
          math.pi,
          math.pi)
      ..close();
    canvas.drawPath(hatPath, fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(13, 19, 34, 4), const Radius.circular(2)),
      fill,
    );

    // Face.
    fill.color = const Color(0xFF2B2320);
    canvas.drawCircle(const Offset(26, 25), 1.6, fill);
    canvas.drawCircle(const Offset(34, 25), 1.6, fill);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF2B2320);
    final mouth = Path()
      ..moveTo(26, 30)
      ..quadraticBezierTo(30, 33, 34, 30);
    canvas.drawPath(mouth, stroke);
  }

  @override
  bool shouldRepaint(_MiniBuddyPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// A mini buddy standing guard on top of an app chip, used in the running
/// session view: the buddy literally sits between you and the app.
class GuardPost extends StatelessWidget {
  const GuardPost({super.key, required this.buddy, required this.appName});

  final MiniBuddy buddy;
  final String appName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MiniBuddyAvatar(buddy: buddy, size: 40),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: buddy.color.withValues(alpha: 0.6)),
          ),
          child: Text(
            appName,
            style: TextStyle(
              fontSize: 10,
              decoration: TextDecoration.lineThrough,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
