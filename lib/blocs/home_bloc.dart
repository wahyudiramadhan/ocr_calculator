// home_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/result_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ResultRepository resultRepository;
  String storageOption = 'file'; // Default option

  HomeBloc(this.resultRepository) : super(HomeLoading()) {
    on<LoadResults>(_onLoadResults);
    on<PickImage>(_onPickImage);
    on<SaveResult>(_onSaveResult);
    on<ChangeStorageOption>(_onChangeStorageOption);
    add(LoadResults());
  }

  Future<void> _onLoadResults(
      LoadResults event, Emitter<HomeState> emit) async {
    try {
      final results = await resultRepository.loadResults();
      emit(HomeLoaded(results));
    } catch (e) {
      emit(HomeError("Failed to load results"));
    }
  }

  Future<void> _onPickImage(PickImage event, Emitter<HomeState> emit) async {
    try {
      final XFile? image =
          await resultRepository.pickImage(event.source, event.context);
      if (image != null) {
        await resultRepository.processImage(event.context, image);
        add(LoadResults());
      }
    } catch (e) {
      emit(HomeError("Failed to pick image"));
    }
  }

  Future<void> _onSaveResult(SaveResult event, Emitter<HomeState> emit) async {
    try {
      await resultRepository.saveResult(
          event.rawData, event.expression, event.result, event.imagePath);
      add(LoadResults());
    } catch (e) {
      emit(HomeError("Failed to save result"));
    }
  }

  void _onChangeStorageOption(
      ChangeStorageOption event, Emitter<HomeState> emit) {
    storageOption = event.option;
  }
}
