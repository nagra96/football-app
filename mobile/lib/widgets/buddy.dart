import 'dart:math' as math;

import 'package:flutter/material.dart';

enum BuddyMood { idle, working, paused, celebrating }

const _moodLines = <BuddyMood, List<String>>{
  BuddyMood.idle: [
    'Ready when you are, boss.',
    "Pick a job and let's clock in.",
    'Tools are sharp and ready.',
  ],
  BuddyMood.working: [
    'On it! Stay on the clock.',
    "Don't touch that phone, we're mid-job.",
    'Almost got this nailed down.',
  ],
  BuddyMood.celebrating: [
    "Job done! Nice work.",
    "That's a wrap — pay day!",
    'Knocked it out of the park.',
  ],
  BuddyMood.paused: [
    'Taking five? Fair enough.',
    "Clock's paused, come back soon.",
  ],
};

String buddyLine(BuddyMood mood, int seed) {
  final lines = _moodLines[mood]!;
  return lines[seed % lines.length];
}

/// Buddy the Apprentice: the big hard-hat mascot.
class BuddyMascot extends StatefulWidget {
  const BuddyMascot({super.key, required this.mood, this.size = 150});

  final BuddyMood mood;
  final double size;

  @override
  State<BuddyMascot> createState() => _BuddyMascotState();
}

class _BuddyMascotState extends State<BuddyMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void initState() {
    super.initState();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(BuddyMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) _syncAnimation();
  }

  void _syncAnimation() {
    switch (widget.mood) {
      case BuddyMood.working:
        _controller.repeat();
      case BuddyMood.celebrating:
        _controller
          ..stop()
          ..duration = const Duration(milliseconds: 500)
          ..forward(from: 0).then((_) {
            _controller.duration = const Duration(milliseconds: 2200);
          });
      case BuddyMood.idle:
      case BuddyMood.paused:
        _controller
          ..stop()
          ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double dy = 0;
        double scale = 1;
        double armAngle = 0;
        if (widget.mood == BuddyMood.working) {
          dy = -5 * math.sin(_controller.value * 2 * math.pi);
          armAngle = 0.12 * math.sin(_controller.value * 4 * math.pi);
        } else if (widget.mood == BuddyMood.celebrating) {
          scale = Curves.elasticOut.transform(_controller.value.clamp(0, 1)) *
                  0.25 +
              0.75;
        }
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _BuddyPainter(mood: widget.mood, armAngle: armAngle),
            ),
          ),
        );
      },
    );
  }
}

class _BuddyPainter extends CustomPainter {
  _BuddyPainter({required this.mood, required this.armAngle});

  final BuddyMood mood;
  final double armAngle;

  static const _hat = Color(0xFFF6A821);
  static const _hatDark = Color(0xFFC97E0F);
  static const _skin = Color(0xFFFFD9A0);
  static const _ink = Color(0xFF2B2320);
  static const _boots = Color(0xFF4A4238);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    canvas.scale(s);

    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5
      ..color = _ink;

    // Left arm (behind body).
    fill.color = _skin;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(24, 56, 8, 24), const Radius.circular(4)),
      fill,
    );

    // Right arm holding a wrench, swings while working.
    canvas.save();
    canvas.translate(72, 58);
    canvas.rotate(armAngle);
    canvas.translate(-72, -58);
    fill.color = _skin;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(68, 56, 8, 24), const Radius.circular(4)),
      fill,
    );
    canvas.save();
    canvas.translate(70, 76);
    canvas.rotate(0.5);
    fill.color = const Color(0xFF8A8A8A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 18, 6), const Radius.circular(3)),
      fill,
    );
    canvas.restore();
    canvas.restore();

    // Body.
    fill.color = _hat;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(30, 52, 40, 34), const Radius.circular(10)),
      fill,
    );

    // Legs.
    fill.color = _boots;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(36, 84, 10, 12), const Radius.circular(3)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(54, 84, 10, 12), const Radius.circular(3)),
      fill,
    );

    // Head.
    fill.color = _skin;
    canvas.drawCircle(const Offset(50, 40), 22, fill);

    // Hard hat: top half of an ellipse plus a brim.
    final hatPath = Path()
      ..addArc(Rect.fromCenter(
          center: const Offset(50, 34), width: 50, height: 40), math.pi, math.pi)
      ..close();
    fill.color = _hat;
    canvas.drawPath(hatPath, fill);
    fill.color = _hatDark;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(22, 32, 56, 6), const Radius.circular(3)),
      fill,
    );

    // Face.
    if (mood == BuddyMood.celebrating) {
      final happy = Path()
        ..moveTo(42, 42)
        ..quadraticBezierTo(45, 46, 48, 42)
        ..moveTo(52, 42)
        ..quadraticBezierTo(55, 46, 58, 42);
      canvas.drawPath(happy, stroke);
    } else {
      fill.color = _ink;
      canvas.drawCircle(const Offset(44, 41), 2.4, fill);
      canvas.drawCircle(const Offset(56, 41), 2.4, fill);
    }

    final mouth = Path();
    switch (mood) {
      case BuddyMood.paused:
        mouth
          ..moveTo(44, 50)
          ..quadraticBezierTo(50, 48, 56, 50);
      case BuddyMood.celebrating:
        mouth
          ..moveTo(42, 48)
          ..quadraticBezierTo(50, 56, 58, 48);
      case BuddyMood.idle:
      case BuddyMood.working:
        mouth
          ..moveTo(43, 49)
          ..quadraticBezierTo(50, 54, 57, 49);
    }
    canvas.drawPath(mouth, stroke);
  }

  @override
  bool shouldRepaint(_BuddyPainter oldDelegate) =>
      oldDelegate.mood != mood || oldDelegate.armAngle != armAngle;
}
