import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:drawing/draw/model/stroke.dart';
import 'package:drawing/draw/model/shape.dart';

Future<Uint8List?> generateThumbnail(
  List<Stroke> strokes,
  List<Shape> shapes,
  int width,
  int height,
) async {
  try {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());

    // Draw white background
    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // Draw all strokes
    for (var stroke in strokes) {
      final paint = Paint()
        ..color = stroke.toColor
        ..strokeWidth = stroke.brushSize
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      if (stroke.points.isNotEmpty) {
        path.moveTo(stroke.points[0].dx, stroke.points[0].dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Draw all shapes
    for (var shape in shapes) {
      final paint = Paint()
        ..color = shape.color
        ..strokeWidth = shape.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      switch (shape.type) {
        case ShapeType.rectangle:
          canvas.drawRect(
            Rect.fromPoints(shape.startPoint, shape.endPoint),
            paint,
          );
          break;
        case ShapeType.circle:
          final center = Offset(
            (shape.startPoint.dx + shape.endPoint.dx) / 2,
            (shape.startPoint.dy + shape.endPoint.dy) / 2,
          );
          final radius = (shape.startPoint - shape.endPoint).distance / 2;
          canvas.drawCircle(center, radius, paint);
          break;
        case ShapeType.line:
          canvas.drawLine(shape.startPoint, shape.endPoint, paint);
          break;
        case ShapeType.text:
          if (shape.text != null && shape.textStyle != null) {
            final textSpan = TextSpan(
              text: shape.text,
              style: shape.textStyle,
            );
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            textPainter.paint(canvas, shape.startPoint);
          }
          break;
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (e) {
    print('Error generating thumbnail: $e');
    return null;
  }
}
