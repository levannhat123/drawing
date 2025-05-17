import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'offset.g.dart';

@HiveType(typeId: 0)
class OffsetCustom extends HiveObject {
  @HiveField(0)
  final double dx;
  @HiveField(1)
  final double dy;
  OffsetCustom({required this.dx, required this.dy});
  Offset toOffset() => Offset(dx, dy);
  factory OffsetCustom.fromOffset(Offset offset) {
    return OffsetCustom(dx: offset.dx, dy: offset.dy);
  }
}
