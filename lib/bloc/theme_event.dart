part of 'theme_bloc.dart';

@immutable
abstract class ThemeEvent {}

class ThemeChangedEvent extends ThemeEvent {
  final bool isDarkMode;

  ThemeChangedEvent(this.isDarkMode);
}
