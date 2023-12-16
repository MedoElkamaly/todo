import 'package:todo/src/resources/models/todo_model.dart';

class TodoFormEvent{}

class UpdateTodoEvent extends TodoFormEvent{
  final TodoModel model;

  UpdateTodoEvent({required this.model});
}

class InsertTodoEvent extends TodoFormEvent{
  final TodoModel model;

  InsertTodoEvent({required this.model});
}