import 'package:todo/src/resources/models/todo_model.dart';

class HomeEvent {}

class GetTodosEvent extends HomeEvent {}
class ReloadTodosEvent extends HomeEvent {}
class RefreshTodosEvent extends HomeEvent {}

class ToggleTodoEvent extends HomeEvent {
  final TodoModel model;

  ToggleTodoEvent({required this.model});
}

class TodoUpdatedEvent extends HomeEvent {
  final TodoModel model;

  TodoUpdatedEvent({required this.model});
}
