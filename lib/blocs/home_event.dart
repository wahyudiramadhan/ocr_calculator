import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

abstract class HomeEvent {}

class LoadResults extends HomeEvent {}

class PickImage extends HomeEvent {
  final ImageSource source;
  final BuildContext context; // Tambahkan BuildContext

  PickImage(this.source, this.context); // Update konstruktor
}

class SaveResult extends HomeEvent {
  final String rawData;
  final String expression;
  final String result;
  final String imagePath;

  SaveResult(this.rawData, this.expression, this.result, this.imagePath);
}

class ChangeStorageOption extends HomeEvent {
  final String option;

  ChangeStorageOption(this.option);
}
