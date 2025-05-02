import 'package:dedo/models/task_model.dart';
import 'package:dedo/repositories/task_repository.dart';
import 'package:dedo/services/notification_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final NotificationHelper notificationHelper;
  final TaskRepository taskRepo;

  TaskBloc(this.taskRepo, this.notificationHelper) : super(TaskInitial()) {
    notificationHelper.init();

    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);

    add(LoadTasks());
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await taskRepo.getAllTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final taskId = await taskRepo.insertTask(event.task);
      await notificationHelper.scheduleTaskNotifications(event.task);
      final tasks = await taskRepo.getAllTasks();
      emit(
        TaskSuccess(
          tasks: tasks,
          message: 'Task added successfully',
          taskId: taskId,
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final taskId = await taskRepo.updateTask(event.task);
      await notificationHelper.updateTaskNotifications(event.task);
      final tasks = await taskRepo.getAllTasks();
      emit(
        TaskSuccess(
          tasks: tasks,
          message: 'Task updated successfully',
          taskId: taskId,
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final task = await taskRepo.getTaskById(event.taskId);
      if (task != null) {
        await notificationHelper.handleTaskDeletion(task);
      }
      await taskRepo.deleteTask(event.taskId);
      final tasks = await taskRepo.getAllTasks();
      emit(TaskSuccess(tasks: tasks, message: 'Task deleted successfully'));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletion(
    ToggleTaskCompletion event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final task = await taskRepo.getTaskById(event.taskId);

      if (task == null) {
        emit(TaskError('Task not found'));
        return;
      }

      final newStatus = !task.isCompleted;

      await taskRepo.toggleTaskCompletion(event.taskId, newStatus);

      final updatedTask = await taskRepo.getTaskById(task.id!);

      await notificationHelper.handleTaskCompletionToggle(
        updatedTask!,
        newStatus,
      );

      final tasks = await taskRepo.getAllTasks();

      emit(
        TaskSuccess(
          tasks: tasks,
          message: 'Task marked as ${newStatus ? 'completed' : 'pending'}',
          taskId: event.taskId,
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
