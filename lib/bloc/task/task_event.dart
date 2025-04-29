part of 'task_bloc.dart';

abstract class TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final TaskModel task;

  AddTaskEvent(this.task);
}
