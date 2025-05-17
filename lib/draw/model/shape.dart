import 'package:flutter/material.dart';

enum ShapeType {
  rectangle,
  circle,
  line,
  text,
}

class Shape {
  final ShapeType type;
  final Offset startPoint;
  final Offset endPoint;
  final Color color;
  final double strokeWidth;
  final String? text; // For text type
  final TextStyle? textStyle; // For text type

  Shape({
    required this.type,
    required this.startPoint,
    required this.endPoint,
    required this.color,
    required this.strokeWidth,
    this.text,
    this.textStyle,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'startPoint': {'dx': startPoint.dx, 'dy': startPoint.dy},
      'endPoint': {'dx': endPoint.dx, 'dy': endPoint.dy},
      'color': color.value,
      'strokeWidth': strokeWidth,
      'text': text,
      'textStyle': textStyle?.fontSize,
    };
  }

  factory Shape.fromJson(Map<String, dynamic> json) {
    return Shape(
      type: ShapeType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      startPoint: Offset(
        json['startPoint']['dx'],
        json['startPoint']['dy'],
      ),
      endPoint: Offset(
        json['endPoint']['dx'],
        json['endPoint']['dy'],
      ),
      color: Color(json['color']),
      strokeWidth: json['strokeWidth'],
      text: json['text'],
      textStyle: json['textStyle'] != null
          ? TextStyle(fontSize: json['textStyle'])
          : null,
    );
  }
}
