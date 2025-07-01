import 'package:flutter/material.dart';

class RectPainter extends CustomPainter {
  final List<Offset> points;

  RectPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 4) return;

    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..lineTo(points[1].dx, points[1].dy)
      ..lineTo(points[2].dx, points[2].dy)
      ..lineTo(points[3].dx, points[3].dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RectPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
