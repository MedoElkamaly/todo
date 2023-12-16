import 'package:equatable/equatable.dart';
import 'package:todo/src/enums/loading_status.dart';
import 'package:todo/src/resources/models/todo_model.dart';

class HomeState extends Equatable {
  final LoadingStatus status;
  final List<TodoModel> todos;
  final int page;
  final bool lastPage;
  final bool errorHandled;
  final String error;

  const HomeState({
    this.status = LoadingStatus.initial,
    this.todos = const <TodoModel>[],
    this.page = 0,
    this.lastPage = false,
    this.errorHandled = true,
    this.error = '',
  });


  /// Creates a new [HomeState] with some of the current objects data, and set
  /// a selective parameters
  HomeState copyWith({
    LoadingStatus? status,
    List<TodoModel>? todos,
    int? page,
    bool? lastPage,
    bool? errorHandled,
    String? error,
  }) {
    return HomeState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      page: page ?? this.page,
      lastPage: lastPage ?? this.lastPage,
      errorHandled: errorHandled ?? true,
      error: error ?? '',
    );
  }

  @override
  List<Object?> get props => [status, todos, page, lastPage, error];
}
