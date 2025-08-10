part of 'task_bloc.dart';

/// Base class for all task-related events in the BLoC.
/// Extends [Equatable] to enable value-based equality,
/// which helps in event comparison and prevents unnecessary rebuilds.
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  /// Default props is empty, subclasses override to specify relevant fields.
  @override
  List<Object> get props => [];
}

/// Event to trigger loading of all tasks.
/// Typically dispatched when the app needs to fetch tasks from a repository or database.
class LoadTasks extends TaskEvent {}

/// Event to add a new task.
/// Carries the [TaskModel] to be added.
/// Using immutable data ensures safe state transitions.
class AddTask extends TaskEvent {
  final TaskModel task;

  const AddTask(this.task);

  @override
  List<Object> get props => [task];
}

/// Event to update an existing task.
/// Contains the updated [TaskModel].
/// Allows the BLoC to handle modifications efficiently.
class UpdateTask extends TaskEvent {
  final TaskModel task;

  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

/// Event to delete a task by its unique identifier.
/// Using taskId rather than the whole model minimizes data passed and simplifies handling.
class DeleteTask extends TaskEvent {
  final int taskId;

  const DeleteTask({required this.taskId});

  @override
  List<Object> get props => [taskId];
}

/// Event to toggle the completion status of a task.
/// Carries both taskId and new completion status.
/// Useful for quick UI updates and syncing state.
class ToggleTaskCompletion extends TaskEvent {
  final int taskId;
  final bool isCompleted;

  const ToggleTaskCompletion(this.taskId, this.isCompleted);

  @override
  List<Object> get props => [taskId, isCompleted];
}

/// Event to load statistics for the current week.
/// Enables the BLoC to fetch and process weekly task-related data.
class LoadWeeklyStats extends TaskEvent {}

/// Event to load the user's current streak.
/// Typically used to show progress or motivate the user.
class LoadStreak extends TaskEvent {}

/// Event to refresh all task-related data.
/// Useful for forcing a full data reload, such as after sync or app restart.
class RefreshAllData extends TaskEvent {}
