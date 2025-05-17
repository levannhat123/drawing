import 'package:hive/hive.dart';
import 'package:drawing/draw/model/shape.dart';

class ShapeAdapter extends TypeAdapter<Shape> {
  @override
  final int typeId = 2;

  @override
  Shape read(BinaryReader reader) {
    final Map<String, dynamic> json = reader.readMap().cast<String, dynamic>();
    return Shape.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, Shape obj) {
    writer.writeMap(obj.toJson());
  }
}
