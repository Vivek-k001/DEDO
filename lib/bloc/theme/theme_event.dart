part of 'theme_bloc.dart';

/// Base class for all theme-related events.
/// Marked as immutable to enforce state consistency and prevent accidental changes.
@immutable
abstract class ThemeEvent {}

/// Event representing a user-triggered theme change.
/// Carries a boolean indicating whether dark mode is enabled.
/// This event drives the theme update logic in [ThemeBloc].
class ThemeChangedEvent extends ThemeEvent {
  final bool isDarkMode;

  ThemeChangedEvent(this.isDarkMode);
}
