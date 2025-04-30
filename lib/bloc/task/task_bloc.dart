import 'package:dedo/db/db_helper.dart';
import 'package:dedo/models/task_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskInitial()) {
    on<LoadTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final rawTasks = await DBHelper.query();
        final tasks = rawTasks.map((task) => TaskModel.fromJson(task)).toList();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<AddTask>((event, emit) async {
      emit(TaskLoading());
      try {
        final taskId = await DBHelper.insert(event.task);
        emit(TaskSuccess(taskId));
        add(LoadTasks());
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<DeleteTask>((event, emit) async {
      emit(TaskLoading());
      try {
        await DBHelper.delete(event.taskId);
        emit(TaskSuccess(event.taskId));
        add(LoadTasks());
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<UpdateSingleField>((event, emit) async {
      emit(TaskLoading());
      try {
        await DBHelper.updateSingleField(
          event.taskId,
          event.field,
          event.value,
        );
        emit(TaskSuccess(event.taskId));
        add(LoadTasks());
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    add(LoadTasks());
  }
}
