import 'dart:typed_data';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:drawing/draw/cubit/draw_state.dart';
import 'package:drawing/draw/thumbnail.dart';
import 'package:drawing/model/stroke.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class DrawCubit extends Cubit<DrawState> {
  DrawCubit() : super(DrawInitial());

  Future<void> initialize(String? drawingName) async {
    final drawingBox = Hive.box<Map<dynamic, dynamic>>('drawingBox');
    List<Stroke> strokes = [];
    if (drawingName != null) {
      final drawingData = drawingBox.get(drawingName);
      strokes =
          (drawingData?['strokes'] as List<dynamic>?)?.cast<Stroke>() ?? [];
    }
    emit(DrawUpdated(
      strokes: strokes,
      redoStrokes: const [],
      currentPoints: const [],
      brushSize: state.brushSize,
      selectedColor: state.selectedColor,
      isErasing: state.isErasing,
      drawingName: drawingName,
      textController: TextEditingController(text: drawingName),
    ));
  }

  void startStroke(Offset point) {
    emit(DrawUpdated(
      strokes: state.strokes,
      redoStrokes: state.redoStrokes,
      currentPoints: [...state.currentPoints, point],
      brushSize: state.brushSize,
      selectedColor: state.selectedColor,
      isErasing: state.isErasing,
      drawingName: state.drawingName,
      textController: state.textController,
    ));
  }

  void updateStroke(Offset point) {
    emit(DrawUpdated(
      strokes: state.strokes,
      redoStrokes: state.redoStrokes,
      currentPoints: [...state.currentPoints, point],
      brushSize: state.brushSize,
      selectedColor: state.selectedColor,
      isErasing: state.isErasing,
      drawingName: state.drawingName,
      textController: state.textController,
    ));
  }

  void endStroke() {
    final newStroke = Stroke.fromPoints(
      points: List.from(state.currentPoints),
      brushSize: state.brushSize,
      color: state.isErasing ? Colors.white : state.selectedColor,
    );
    emit(DrawUpdated(
      strokes: [...state.strokes, newStroke],
      redoStrokes: const [],
      currentPoints: const [],
      brushSize: state.brushSize,
      selectedColor: state.selectedColor,
      isErasing: state.isErasing,
      drawingName: state.drawingName,
      textController: state.textController,
    ));
  }

  void undo() {
    if (state.strokes.isNotEmpty) {
      final lastStroke = state.strokes.last;
      emit(DrawUpdated(
        strokes: state.strokes.sublist(0, state.strokes.length - 1),
        redoStrokes: [...state.redoStrokes, lastStroke],
        currentPoints: state.currentPoints,
        brushSize: state.brushSize,
        selectedColor: state.selectedColor,
        isErasing: state.isErasing,
        drawingName: state.drawingName,
        textController: state.textController,
      ));
    }
  }

  void redo() {
    if (state.redoStrokes.isNotEmpty) {
      final lastRedoStroke = state.redoStrokes.last;
      emit(DrawUpdated(
        strokes: [...state.strokes, lastRedoStroke],
        redoStrokes: state.redoStrokes.sublist(0, state.redoStrokes.length - 1),
        currentPoints: state.currentPoints,
        brushSize: state.brushSize,
        selectedColor: state.selectedColor,
        isErasing: state.isErasing,
        drawingName: state.drawingName,
        textController: state.textController,
      ));
    }
  }

  void changeColor(Color color) {
    emit(DrawUpdated(
      strokes: state.strokes,
      redoStrokes: state.redoStrokes,
      currentPoints: state.currentPoints,
      brushSize: state.brushSize,
      selectedColor: color,
      isErasing: false,
      drawingName: state.drawingName,
      textController: state.textController,
    ));
  }

  void toggleEraser() {
    emit(DrawUpdated(
      strokes: state.strokes,
      redoStrokes: state.redoStrokes,
      currentPoints: state.currentPoints,
      brushSize: state.brushSize,
      selectedColor: state.isErasing ? Colors.black : Colors.white,
      isErasing: !state.isErasing,
      drawingName: state.drawingName,
      textController: state.textController,
    ));
  }

  void changeBrushSize(double size) {
    emit(DrawUpdated(
      strokes: state.strokes,
      redoStrokes: state.redoStrokes,
      currentPoints: state.currentPoints,
      brushSize: size,
      selectedColor: state.selectedColor,
      isErasing: state.isErasing,
      drawingName: state.drawingName,
      textController: state.textController,
    ));
  }

  Future<void> saveDrawing() async {
    final drawingBox = Hive.box<Map<dynamic, dynamic>>('drawingBox');
    final Uint8List? thumbnail =
        await generateThumbnail(state.strokes, 200, 200);

    // Lấy tên từ textController
    final newName = state.textController.text.trim();
    if (newName.isEmpty) return;

    // Nếu đang chỉnh sửa và tên mới khác tên gốc, xóa mục cũ
    if (state.drawingName != null && state.drawingName != newName) {
      await drawingBox.delete(state.drawingName);
    }

    // Lưu bản vẽ với tên mới hoặc tên gốc
    await drawingBox.put(newName, {
      'strokes': state.strokes,
      'thumbnail': thumbnail,
    });

    emit(DrawUpdated(
      strokes: state.strokes,
      redoStrokes: state.redoStrokes,
      currentPoints: state.currentPoints,
      brushSize: state.brushSize,
      selectedColor: state.selectedColor,
      isErasing: state.isErasing,
      drawingName: newName,
      textController: state.textController,
    ));
  }

  Future<String?> downloadDrawing() async {
    if (state.strokes.isEmpty) return 'Bạn chưa vẽ gì để tải về!';

    try {
      final Uint8List? imageData =
          await generateThumbnail(state.strokes, 800, 800);
      if (imageData == null) return 'Không thể tạo hình ảnh';

      final directory = await getExternalStorageDirectory();
      final String filePath =
          '${directory!.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';

      final File file = File(filePath);
      await file.writeAsBytes(imageData);

      return 'Bản vẽ đã được lưu tại: $filePath';
    } catch (e) {
      return 'Lỗi khi lưu bản vẽ: $e';
    }
  }

  @override
  Future<void> close() {
    state.textController.dispose();
    return super.close();
  }
}
