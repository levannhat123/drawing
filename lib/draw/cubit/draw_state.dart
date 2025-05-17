import 'package:drawing/model/stroke.dart';
import 'package:flutter/material.dart';

@immutable
abstract class DrawState {
  final List<Stroke> strokes;
  final List<Stroke> redoStrokes;
  final List<Offset> currentPoints;
  final double brushSize;
  final Color selectedColor;
  final bool isErasing;
  final String? drawingName;
  final TextEditingController textController;

  const DrawState({
    required this.strokes,
    required this.redoStrokes,
    required this.currentPoints,
    required this.brushSize,
    required this.selectedColor,
    required this.isErasing,
    this.drawingName,
    required this.textController,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawState &&
          runtimeType == other.runtimeType &&
          strokes == other.strokes &&
          redoStrokes == other.redoStrokes &&
          currentPoints == other.currentPoints &&
          brushSize == other.brushSize &&
          selectedColor == other.selectedColor &&
          isErasing == other.isErasing &&
          drawingName == other.drawingName &&
          textController == other.textController;

  @override
  int get hashCode =>
      strokes.hashCode ^
      redoStrokes.hashCode ^
      currentPoints.hashCode ^
      brushSize.hashCode ^
      selectedColor.hashCode ^
      isErasing.hashCode ^
      drawingName.hashCode ^
      textController.hashCode;
}

class DrawInitial extends DrawState {
  DrawInitial()
      : super(
          strokes: const [],
          redoStrokes: const [],
          currentPoints: const [],
          brushSize: 4.0,
          selectedColor: Colors.black,
          isErasing: false,
          textController: TextEditingController(),
        );
}

class DrawUpdated extends DrawState {
  const DrawUpdated({
    required super.strokes,
    required super.redoStrokes,
    required super.currentPoints,
    required super.brushSize,
    required super.selectedColor,
    required super.isErasing,
    super.drawingName,
    required super.textController,
  });
}
