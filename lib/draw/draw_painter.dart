import 'package:drawing/model/stroke.dart';
import 'package:flutter/material.dart';

class DrawPainter extends CustomPainter {
  final List<Stroke> strokes;
  final List<Offset> currentPoints;
  final double brushSize;
  final Color color;

  DrawPainter(
    this.strokes,
    this.currentPoints,
    this.brushSize,
    this.color,
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      final paint = Paint()
        ..color = stroke.toColor
        ..strokeWidth = stroke.brushSize
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length > 1) {
        final path = Path();
        path.moveTo(stroke.points[0].dx, stroke.points[0].dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    if (currentPoints.isNotEmpty) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = brushSize
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(currentPoints[0].dx, currentPoints[0].dy);
      for (int i = 1; i < currentPoints.length; i++) {
        path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(DrawPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentPoints != currentPoints ||
        oldDelegate.brushSize != brushSize ||
        oldDelegate.color != color;
  }
}
