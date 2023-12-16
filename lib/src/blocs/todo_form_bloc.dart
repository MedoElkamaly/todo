import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:todo/src/enums/loading_status.dart';
import 'package:todo/src/events/todo_form_event.dart';
import 'package:todo/src/exceptions/my_app_exception.dart';
import 'package:todo/src/resources/todo_repository.dart';
import 'package:todo/src/states/todo_form_state.dart';

class TodoFormBloc extends Bloc<TodoFormEvent, TodoFormState> {
  final _logger = Logger();
  late final TodoRepository _repository;

  TodoFormBloc() : super(const TodoFormState()) {
    _repository = TodoRepository();
    on<UpdateTodoEvent>(_updateTodo);
    on<InsertTodoEvent>(_insertTodo);
  }

  /// Responds to [UpdateTodoEvent] and update a [TodoModel] in [TodoRepository]
  /// then emit a new [TodoFormState]
  Future<void> _updateTodo(
      UpdateTodoEvent event, Emitter<TodoFormState> emit) async {
    emit(state.copyWith(status: LoadingStatus.loading));
    try {
      var updatedModel = await _repository.updateTodo(event.model);

      return emit(state.copyWith(
        status: LoadingStatus.loaded,
        model: updatedModel,
      ));
    } on Exception catch (e) {
      if (e is! MyAppException) {
        _logger.e(e.toString());
      }
      emit(state.copyWith(
          status: LoadingStatus.error, error: 'Unable to update todo'));
    }
  }

  /// Responds to [InsertTodoEvent] and insert a new [TodoModel] in [TodoRepository]
  /// then emit a new [TodoFormState]
  Future<void> _insertTodo(
      InsertTodoEvent event, Emitter<TodoFormState> emit) async {
    emit(state.copyWith(status: LoadingStatus.loading));
    try {
      var insertedModel = await _repository.insertTodo(event.model);

      return emit(state.copyWith(
        status: LoadingStatus.loaded,
        model: insertedModel,
      ));
    } on Exception catch (e) {
      if (e is! MyAppException) {
        _logger.e(e.toString());
      }
      emit(state.copyWith(
          status: LoadingStatus.error, error: 'Unable to insert todo'));
    }
  }
}
