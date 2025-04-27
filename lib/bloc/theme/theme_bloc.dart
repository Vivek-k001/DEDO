import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
part 'theme_event.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  final _storage = GetStorage();

  ThemeBloc() : super(ThemeMode.light) {
    on<ThemeChangedEvent>((event, emit) {
      final newTheme = event.isDarkMode ? ThemeMode.dark : ThemeMode.light;
      _storage.write("isDarkMode", event.isDarkMode);
      emit(newTheme);
    });
  }
}
