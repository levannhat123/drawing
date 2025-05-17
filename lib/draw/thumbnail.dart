import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:drawing/model/stroke.dart';

Future<Uint8List?> generateThumbnail(
  List<Stroke> strokes,
  int width,
  int height,
) async {
  try {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());

    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

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

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (e) {
    print('Error generating thumbnail: $e');
    return null;
  }
}
