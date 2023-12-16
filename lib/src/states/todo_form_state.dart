import 'package:equatable/equatable.dart';
import 'package:todo/src/enums/loading_status.dart';
import 'package:todo/src/resources/models/todo_model.dart';

class TodoFormState extends Equatable {
  final LoadingStatus status;
  final TodoModel? model;
  final String error;

  const TodoFormState({
    this.status = LoadingStatus.initial,
    this.model,
    this.error = '',
  });

  /// Creates a new [TodoFormState] with some of the current objects data, and set
  /// a selective parameters
  TodoFormState copyWith({
    LoadingStatus? status,
    TodoModel? model,
    String? error,
  }) {
    return TodoFormState(
      status: status ?? this.status,
      model: model,
      error: error ?? '',
    );
  }

  @override
  List<Object?> get props => [status, model];
}
