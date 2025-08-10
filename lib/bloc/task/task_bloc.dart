import 'package:dedo/models/task_model.dart';
import 'package:dedo/repositories/task_repository.dart';
import 'package:dedo/services/notification_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'task_event.dart';
part 'task_state.dart';

/// BLoC responsible for managing all task-related operations.
/// It handles loading, adding, updating, deleting tasks,
/// as well as computing weekly stats and tracking task streaks.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepo;
  final TaskNotificationHelper notificationHelper;

  // Internal state to keep current data for building composite states
  List<TaskModel> _currentTasks = [];
  List<double> _currentWeeklyStats = List.filled(
    7,
    0,
  ); // Stats for each weekday
  int _currentStreak = 0;

  TaskBloc(this.taskRepo, this.notificationHelper) : super(TaskInitial()) {
    // Registering event handlers
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<LoadWeeklyStats>(_onLoadWeeklyStats);
    on<LoadStreak>(_onLoadStreak);
    on<RefreshAllData>(_onRefreshAllData);

    // Load initial data on BLoC creation
    add(RefreshAllData());
  }

  /// Loads all tasks and emits them as a composite state.
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await taskRepo.getAllTasks();
      _currentTasks = tasks;
      emit(_buildCompositeState());
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  /// Adds a new task, schedules notification, and refreshes all data.
  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final taskId = await taskRepo.insertTask(event.task);
      final taskWithId = event.task.copyWith(id: taskId);
      await notificationHelper.scheduleTaskNotifications(taskWithId);
      await _refreshAllData();
      emit(
        TaskSuccess(
          tasks: _currentTasks,
          weeklyStats: _currentWeeklyStats,
          streakDays: _currentStreak,
          message: 'Task added successfully',
          taskId: taskId,
        ),
      );
    } catch (e) {
      emit(TaskError('Failed to add task: $e'));
    }
  }

  /// Updates an existing task, reschedules its notification, and refreshes data.
  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await notificationHelper.cancelTaskNotifications(event.task);
      final taskId = await taskRepo.updateTask(event.task);
      await notificationHelper.scheduleTaskNotifications(event.task);
      await _refreshAllData();
      emit(
        TaskSuccess(
          tasks: _currentTasks,
          weeklyStats: _currentWeeklyStats,
          streakDays: _currentStreak,
          message: 'Task updated successfully',
          taskId: taskId,
        ),
      );
    } catch (e) {
      emit(TaskError('Failed to update task: $e'));
    }
  }

  /// Deletes a task, cancels its notification if present, and refreshes all data.
  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final task = await taskRepo.getTaskById(event.taskId);
      if (task != null) {
        await notificationHelper.cancelTaskNotifications(task);
      }
      await taskRepo.deleteTask(event.taskId);
      await _refreshAllData();
      emit(
        TaskSuccess(
          tasks: _currentTasks,
          weeklyStats: _currentWeeklyStats,
          streakDays: _currentStreak,
          message: 'Task deleted successfully',
        ),
      );
    } catch (e) {
      emit(TaskError('Failed to delete task: $e'));
    }
  }

  /// Toggles the completion status of a task and updates notification accordingly.
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

      final updatedTask = await taskRepo.getTaskById(event.taskId);
      if (updatedTask != null) {
        if (newStatus) {
          await notificationHelper.cancelTaskNotifications(updatedTask);
        } else {
          await notificationHelper.scheduleTaskNotifications(updatedTask);
        }
      }

      await _refreshAllData();
      emit(
        TaskSuccess(
          tasks: _currentTasks,
          weeklyStats: _currentWeeklyStats,
          streakDays: _currentStreak,
          message: 'Task marked as ${newStatus ? 'completed' : 'pending'}',
          taskId: event.taskId,
        ),
      );
    } catch (e) {
      emit(TaskError('Failed to toggle completion: $e'));
    }
  }

  /// Loads task completion statistics for the current week.
  Future<void> _onLoadWeeklyStats(
    LoadWeeklyStats event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final weeklyStats = await taskRepo.getCurrentWeekCompletionStats();
      _currentWeeklyStats = weeklyStats;
      emit(_buildCompositeState());
    } catch (e) {
      emit(TaskError('Failed to load weekly stats: $e'));
    }
  }

  /// Loads the current completion streak.
  Future<void> _onLoadStreak(LoadStreak event, Emitter<TaskState> emit) async {
    try {
      final streak = await taskRepo.getCurrentStreak();
      _currentStreak = streak;
      emit(_buildCompositeState());
    } catch (e) {
      emit(TaskError('Failed to load streak: $e'));
    }
  }

  /// Refreshes all task-related data (tasks, stats, streak) and emits as a combined state.
  Future<void> _onRefreshAllData(
    RefreshAllData event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      await _refreshAllData();
      emit(_buildCompositeState());
    } catch (e) {
      emit(TaskError('Failed to refresh data: $e'));
    }
  }

  /// Helper method to load all data sources concurrently and update internal state.
  Future<void> _refreshAllData() async {
    final futures = await Future.wait([
      taskRepo.getAllTasks(),
      taskRepo.getCurrentWeekCompletionStats(),
      taskRepo.getCurrentStreak(),
    ]);

    _currentTasks = futures[0] as List<TaskModel>;
    _currentWeeklyStats = futures[1] as List<double>;
    _currentStreak = futures[2] as int;
  }

  /// Combines the current tasks, weekly stats, and streak into a single unified state.
  TaskState _buildCompositeState() {
    return TaskDataLoaded(
      tasks: _currentTasks,
      weeklyStats: _currentWeeklyStats,
      streakDays: _currentStreak,
    );
  }
}
