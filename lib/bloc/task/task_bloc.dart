import 'package:dedo/db/db_helper.dart';
import 'package:dedo/models/task_model.dart';
import 'package:dedo/services/notification_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'task_event.dart';
part 'task_state.dart';

final NotificationHelper _notificationHelper = NotificationHelper();

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskInitial()) {
    _notificationHelper.init();

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
        await _notificationHelper.scheduleTaskNotifications(event.task);
        emit(TaskSuccess(taskId));
        add(LoadTasks());
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<DeleteTask>((event, emit) async {
      emit(TaskLoading());
      try {
        final taskJson = await DBHelper.queryById(event.taskId);
        final task = TaskModel.fromJson(taskJson!);

        await DBHelper.delete(event.taskId);

        await _notificationHelper.handleTaskDeletion(task);

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

        final taskJson = await DBHelper.queryById(event.taskId);
        final task = TaskModel.fromJson(taskJson!);

        if (event.field == "isCompleted") {
          bool isCompleted = event.value == 1 ? true : false;

          await _notificationHelper.handleTaskCompletionToggle(
            task,
            isCompleted,
          );
        }

        if ([
          "date",
          "startTime",
          "endTime",
          "remind",
          "repeat",
        ].contains(event.field)) {
          await _notificationHelper.updateTaskNotifications(task);
        }

        emit(TaskSuccess(event.taskId));
        add(LoadTasks());
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    add(LoadTasks());
  }
}
