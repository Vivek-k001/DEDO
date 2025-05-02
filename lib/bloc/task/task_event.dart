part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final TaskModel task;

  const AddTask(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final TaskModel task;

  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final int taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class ToggleTaskCompletion extends TaskEvent {
  final int taskId;
  final bool isCompleted;

  const ToggleTaskCompletion(this.taskId, this.isCompleted);

  @override
  List<Object> get props => [taskId, isCompleted];
}
