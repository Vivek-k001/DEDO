import 'package:dedo/db/db_helper.dart';
import 'package:dedo/models/taskmodel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskInitial()) {
    on<AddTaskEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        final taskId = await DBHelper.insert(event.task);
        emit(TaskSuccess(taskId));
      } catch (e) {
        emit(TaskFailure(e.toString()));
      }
    });
  }
}

Future<int> addTask({Task? task}) async {
  return await DBHelper.insert(task);
}

abstract class TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final Task task;

  AddTaskEvent(this.task);
}

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
