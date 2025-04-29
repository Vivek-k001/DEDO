part of 'task_bloc.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;

  TaskLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskSuccess extends TaskState {
  final int taskId;

  TaskSuccess(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
