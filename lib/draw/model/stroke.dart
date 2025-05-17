import 'package:drawing/draw/model/offset.dart';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
part 'stroke.g.dart';

@HiveType(typeId: 1)
class Stroke extends HiveObject {
  @HiveField(0)
  final List<OffsetCustom> points;
  @HiveField(1)
  final int color;
  @HiveField(2)
  final double brushSize;

  Stroke({required this.points, required this.color, required this.brushSize});

  List<Offset> get toPoints {
    return points.map((e) => e.toOffset()).toList();
  }

  Color get toColor {
    return Color(color);
  }

  factory Stroke.fromPoints(Map<String, dynamic> s,
      {required List points, required double brushSize, required Color color}) {
    return Stroke(
      points: points.map((e) => OffsetCustom.fromOffset(e)).toList(),
      color: color.value,
      brushSize: brushSize,
    );
  }
}
