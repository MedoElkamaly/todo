import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:todo/src/enums/loading_status.dart';
import 'package:todo/src/events/home_event.dart';
import 'package:todo/src/exceptions/my_app_exception.dart';
import 'package:todo/src/resources/todo_repository.dart';
import 'package:todo/src/states/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final _logger = Logger();
  late final TodoRepository _repository;

  HomeBloc() : super(const HomeState()) {
    _repository = TodoRepository();
    on<GetTodosEvent>(_getTodos);
    on<ReloadTodosEvent>(_reloadTodo);
    on<RefreshTodosEvent>(_refreshTodo);
    on<ToggleTodoEvent>(_toggleTodo);
    on<TodoUpdatedEvent>(_todoUpdated);
  }

  /// Responds to [GetTodosEvent] and retrieves the next page from [TodoRepository]
  /// then emit a new [HomeState]
  Future<void> _getTodos(GetTodosEvent event, Emitter<HomeState> emit) async {
    if (state.lastPage) return;
    try {
      int newPage = state.page + 1;
      var (list, lastPage) = await _repository.getTodos(newPage);
      return emit(state.copyWith(
        status: LoadingStatus.loaded,
        todos: List.of(state.todos)..addAll(list),
        page: newPage,
        lastPage: lastPage,
      ));
    } on Exception catch (e) {
      if (e is! MyAppException) {
        _logger.e(e.toString());
      }
      emit(state.copyWith(
        status: LoadingStatus.error,
        error: '',
      ));
      emit(state.copyWith(
        status: LoadingStatus.error,
        error: 'Something went wrong',
      ));
    }
  }

  /// Responds to [ReloadTodosEvent] and retrieves the first page from [TodoRepository]
  /// then emit a new [HomeState]
  Future<void> _reloadTodo(
      ReloadTodosEvent event, Emitter<HomeState> emit) async {
    try {
      var (list, lastPage) = await _repository.getTodos(1);
      return emit(state.copyWith(
        status: LoadingStatus.loaded,
        todos: list,
        page: 1,
        lastPage: lastPage,
      ));
    } on Exception catch (e) {
      if (e is! MyAppException) {
        _logger.e(e.toString());
      }
      emit(state.copyWith(
        status: LoadingStatus.error,
        error: '',
      ));
      emit(state.copyWith(
          status: LoadingStatus.error, error: 'Something went wrong'));
    }
  }

  /// Responds to [RefreshTodosEvent], clears the cache and retrieves the first page from [TodoRepository]
  /// then emit a new [HomeState]
  Future<void> _refreshTodo(
      RefreshTodosEvent event, Emitter<HomeState> emit) async {
    try {
      var (list, lastPage) = await _repository.refreshTodos();
      emit(state.copyWith(
        status: LoadingStatus.loaded,
        todos: [],
      ));
      return emit(state.copyWith(
        status: LoadingStatus.loaded,
        todos: list,
        page: 1,
        lastPage: lastPage,
      ));
    } on Exception catch (e) {
      if (e is! MyAppException) {
        _logger.e(e.toString());
      }
      emit(state.copyWith(
        status: LoadingStatus.error,
        error: '',
      ));
      emit(state.copyWith(
          status: LoadingStatus.error, error: 'Something went wrong'));
    }
  }

  /// Responds to [ToggleTodoEvent] and updates the completeness of [TodoModel]
  /// in [TodoRepository] then emit a new [HomeState] with the updated [TodoModel]
  Future<void> _toggleTodo(
      ToggleTodoEvent event, Emitter<HomeState> emit) async {
    try {
      var updatedModel = await _repository.updateTodo(
          event.model.copyWith(isCompleted: !event.model.isCompleted));
      var index =
          state.todos.indexWhere((element) => element.id == updatedModel.id);
      return emit(state.copyWith(
        status: LoadingStatus.loaded,
        todos: List.of(state.todos)
          ..replaceRange(index, index + 1, [updatedModel]),
      ));
    } on Exception catch (e) {
      if (e is! MyAppException) {
        _logger.e(e.toString());
      }
      emit(state.copyWith(
        status: LoadingStatus.error,
        error: '',
      ));
      emit(state.copyWith(
          status: LoadingStatus.error,
          error: 'Unable to update todo',
          errorHandled: false));
    }
  }

  /// Responds to [TodoUpdatedEvent] and replace the updated [TodoModel] with the
  /// old one in the current [HomeState]
  Future<void> _todoUpdated(
      TodoUpdatedEvent event, Emitter<HomeState> emit) async {
    var index =
        state.todos.indexWhere((element) => element.id == event.model.id);
    return emit(state.copyWith(
      status: LoadingStatus.loaded,
      todos: List.of(state.todos)
        ..replaceRange(index, index + 1, [event.model]),
    ));
  }
}
