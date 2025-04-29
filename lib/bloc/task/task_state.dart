part of 'task_bloc.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskSuccess extends TaskState {
  final int taskId;

  TaskSuccess(this.taskId);
}

class TaskFailure extends TaskState {
  final String error;

  TaskFailure(this.error);
}
