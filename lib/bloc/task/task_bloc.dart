import 'package:dedo/db/db_helper.dart';
import 'package:dedo/models/task_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'task_event.dart';
part 'task_state.dart';

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
