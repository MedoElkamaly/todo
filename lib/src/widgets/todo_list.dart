import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/src/blocs/home_bloc.dart';
import 'package:todo/src/events/home_event.dart';
import 'package:todo/src/resources/models/todo_model.dart';
import 'package:todo/src/widgets/todo_item.dart';
import 'package:todo/src/widgets/todo_shimmer_item.dart';

/// A custom [ListView] with [RefreshIndicator] at the top
class TodoList extends StatelessWidget {
  final ScrollController controller;
  final List<TodoModel> todos;
  final bool lastPage;

  const TodoList({
    super.key,
    required this.todos,
    required this.controller,
    required this.lastPage,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        Future block = context.read<HomeBloc>().stream.first;
        context.read<HomeBloc>().add(RefreshTodosEvent());
        await block;
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller,
        itemCount:
            lastPage || todos.isEmpty ? todos.length : todos.length + 1,
        itemBuilder: (context, index) {
          if (index < todos.length) {
            return TodoItem(model: todos[index]);
          } else {
            return const TodoShimmerItem();
          }
        },
      ),
    );
  }
}
