import 'dart:typed_data';
import 'package:flutter/foundation.dart';

@immutable
class DrawingItem {
  final String name;
  final Uint8List? thumbnail;

  const DrawingItem({
    required this.name,
    this.thumbnail,
  });
}

@immutable
abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<DrawingItem> drawings;

  const HomeLoaded(this.drawings);
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}
