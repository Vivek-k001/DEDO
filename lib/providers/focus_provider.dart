import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';

enum FocusClockStyle {
  clock1, // Squircle dial tick thumbnail & perimeter progress
  clock2, // iOS lockscreen bold rounded display
}

class FocusState {
  final bool isRunning;
  final int totalSeconds;
  final int remainingSeconds;
  final Task? activeTask;
  final FocusClockStyle clockStyle;
  final int? customColorValue;

  const FocusState({
    this.isRunning = false,
    this.totalSeconds = 15 * 60,
    this.remainingSeconds = 15 * 60,
    this.activeTask,
    this.clockStyle = FocusClockStyle.clock1,
    this.customColorValue,
  });

  FocusState copyWith({
    bool? isRunning,
    int? totalSeconds,
    int? remainingSeconds,
    Task? Function()? activeTask,
    FocusClockStyle? clockStyle,
    int? Function()? customColorValue,
  }) {
    return FocusState(
      isRunning: isRunning ?? this.isRunning,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      activeTask: activeTask != null ? activeTask() : this.activeTask,
      clockStyle: clockStyle ?? this.clockStyle,
      customColorValue: customColorValue != null ? customColorValue() : this.customColorValue,
    );
  }

  double get progress {
    if (totalSeconds <= 0) return 0.0;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }
}

class FocusNotifier extends StateNotifier<FocusState> {
  Timer? _timer;

  FocusNotifier() : super(const FocusState());

  void startFocus({Task? task, int minutes = 15}) {
    _timer?.cancel();
    final secs = minutes * 60;
    state = state.copyWith(
      isRunning: true,
      totalSeconds: secs,
      remainingSeconds: secs,
      activeTask: () => task ?? state.activeTask,
    );
    _startTimer();
  }

  void resume() {
    if (state.remainingSeconds > 0) {
      state = state.copyWith(isRunning: true);
      _startTimer();
    }
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void togglePlayPause() {
    if (state.isRunning) {
      pause();
    } else {
      resume();
    }
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      remainingSeconds: state.totalSeconds,
    );
  }

  void setDuration(int minutes) {
    _timer?.cancel();
    final secs = minutes * 60;
    state = state.copyWith(
      isRunning: false,
      totalSeconds: secs,
      remainingSeconds: secs,
    );
  }

  void setTask(Task? task) {
    state = state.copyWith(activeTask: () => task);
  }

  void setClockStyle(FocusClockStyle style) {
    state = state.copyWith(clockStyle: style);
  }

  void cycleColor() {
    const palette = [
      0xFF0A84FF, // iOS Electric Blue
      0xFF30D158, // iOS Apple Mint Green
      0xFFFF375F, // iOS Radiant Rose Pink
      0xFFBF5AF2, // iOS Neon Purple
      0xFFFF9F0A, // iOS Bright Tangerine
      0xFF64D2FF, // iOS Sky Cyan
    ];
    final current = state.customColorValue ?? 0xFF0A84FF;
    final nextIndex = (palette.indexOf(current) + 1) % palette.length;
    state = state.copyWith(customColorValue: () => palette[nextIndex]);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        state = state.copyWith(
          remainingSeconds: 0,
          isRunning: false,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusProvider = StateNotifierProvider<FocusNotifier, FocusState>((ref) {
  return FocusNotifier();
});
