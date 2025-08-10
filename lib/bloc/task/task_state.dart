part of 'task_bloc.dart';

/// Base class for all states in the Task BLoC.
/// Extends [Equatable] to facilitate efficient state comparison and avoid redundant UI rebuilds.
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

/// Initial state of the Task BLoC.
/// Represents the state before any tasks have been loaded or processed.
class TaskInitial extends TaskState {}

/// Represents a loading state while tasks or related data are being fetched.
/// Useful to show loading indicators in the UI.
class TaskLoading extends TaskState {}

/// State representing successful loading of tasks.
/// Carries the list of [TaskModel] instances to be displayed or processed.
class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;

  const TaskLoaded({required this.tasks});

  @override
  List<Object> get props => [tasks];
}

/// Represents a success state with rich data including tasks, weekly stats, streak, and a message.
/// This state supports communicating additional context (e.g., operation success message).
/// Optional [taskId] can be used to highlight or focus on a specific task after an operation.
class TaskSuccess extends TaskState {
  final List<TaskModel> tasks;
  final List<double> weeklyStats;
  final int streakDays;
  final String message;
  final int? taskId;

  const TaskSuccess({
    required this.tasks,
    required this.weeklyStats,
    required this.streakDays,
    required this.message,
    this.taskId,
  });

  @override
  List<Object> get props => [
    tasks,
    weeklyStats,
    streakDays,
    message,
    taskId ??
        0, // Use 0 if taskId is null to maintain consistent equality checks
  ];
}

/// Represents an error state with a descriptive message.
/// Useful for showing error alerts or retry options in the UI.
class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}

/// State indicating that multiple key pieces of task data have been loaded:
/// the tasks themselves, weekly stats, and streak days.
/// Separates concerns for UI components that need all these together.
class TaskDataLoaded extends TaskState {
  final List<TaskModel> tasks;
  final List<double> weeklyStats;
  final int streakDays;

  const TaskDataLoaded({
    required this.tasks,
    required this.weeklyStats,
    required this.streakDays,
  });

  @override
  List<Object> get props => [tasks, weeklyStats, streakDays];
}

/// State specifically for when weekly statistics have been loaded.
/// Allows focused UI updates when only stats change.
class WeeklyStatsLoaded extends TaskState {
  final List<double> weeklyStats;

  const WeeklyStatsLoaded(this.weeklyStats);

  @override
  List<Object> get props => [weeklyStats];
}

/// State specifically for when the user's streak data has been loaded.
/// Useful to isolate updates related to streak progress.
class StreakLoaded extends TaskState {
  final int streakDays;

  const StreakLoaded(this.streakDays);

  @override
  List<Object> get props => [streakDays];
}
