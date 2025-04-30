part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final TaskModel task;

  AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final TaskModel task;

  UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateSingleField extends TaskEvent {
  final int taskId;
  final String field;
  final dynamic value;

  UpdateSingleField(this.taskId, this.field, this.value);

  @override
  List<Object?> get props => [taskId, field, value];
}

class DeleteTask extends TaskEvent {
  final int taskId;

  DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}
