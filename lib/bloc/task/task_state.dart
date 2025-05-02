part of 'task_bloc.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;

  const TaskLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class TaskSuccess extends TaskState {
  final List<TaskModel> tasks;
  final String message;
  final int? taskId;

  const TaskSuccess({required this.tasks, required this.message, this.taskId});

  @override
  List<Object> get props => [tasks, message, taskId ?? 0];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}
