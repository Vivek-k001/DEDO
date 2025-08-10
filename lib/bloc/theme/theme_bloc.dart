import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
part 'theme_event.dart';

/// BLoC responsible for managing the application's theme mode (light/dark).
/// Persists user preference locally using `GetStorage` to retain theme choice across app restarts.
class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  // Storage instance for saving and retrieving the theme preference.
  final _storage = GetStorage();

  /// Initializes the BLoC with the persisted theme mode.
  /// Listens for [ThemeChangedEvent] to update the theme and persist the new choice.
  ThemeBloc() : super(_getInitialTheme()) {
    on<ThemeChangedEvent>((event, emit) {
      // Determine new theme mode based on event payload.
      final newTheme = event.isDarkMode ? ThemeMode.dark : ThemeMode.light;

      // Persist the user's theme preference for future app launches.
      _storage.write("isDarkMode", event.isDarkMode);

      // Emit the new theme state to update the UI reactively.
      emit(newTheme);
    });
  }

  /// Retrieves the initial theme mode from local storage.
  /// Defaults to light mode if no preference is saved.
  static ThemeMode _getInitialTheme() {
    final box = GetStorage();
    final isDarkMode = box.read("isDarkMode") ?? false;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}
