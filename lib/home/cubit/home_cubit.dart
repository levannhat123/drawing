import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final Box<Map<dynamic, dynamic>> _drawingBox;

  HomeCubit()
      : _drawingBox = Hive.box<Map<dynamic, dynamic>>('drawingBox'),
        super(const HomeInitial());

  Future<void> loadDrawings() async {
    try {
      emit(const HomeLoading());

      final drawings = _drawingBox.keys.cast<String>().map((key) {
        final data = _drawingBox.get(key);
        return DrawingItem(
          name: key,
          thumbnail: data?['thumbnail'] as Uint8List?,
        );
      }).toList();

      emit(HomeLoaded(drawings));
    } catch (e) {
      emit(HomeError('Đã xảy ra lỗi khi tải bản vẽ: $e'));
    }
  }

  Future<void> refreshDrawings() async {
    await loadDrawings();
  }

  Future<void> deleteDrawing(String name) async {
    try {
      await _drawingBox.delete(name);
      await loadDrawings(); // reload sau khi xóa
    } catch (e) {
      emit(HomeError('Không thể xóa bản vẽ: $e'));
    }
  }
}
