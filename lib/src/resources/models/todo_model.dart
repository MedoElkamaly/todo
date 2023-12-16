import 'package:equatable/equatable.dart';

class TodoModel extends Equatable {
  const TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.isCompleted,
  });

  final int id;
  final int userId;
  final String title;
  final bool isCompleted;

  TodoModel copyWith({
    int? id,
    int? userId,
    String? title,
    bool? isCompleted,
  }) {
    return TodoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  TodoModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        userId = map['userId'],
        title = map['title'],
        isCompleted =
            map['completed'] is bool ? map['completed'] : map['completed'] != 0;

  Map<String, dynamic> toMap({bool toDb = false}) {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'completed': toDb ? (isCompleted ? 1 : 0) : isCompleted,
    };
  }

  @override
  List<Object> get props => [id, title, userId, isCompleted];
}
