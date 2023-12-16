import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/src/blocs/home_bloc.dart';
import 'package:todo/src/events/home_event.dart';
import 'package:todo/src/resources/models/todo_model.dart';
import 'package:todo/src/screens/todo_form_screen.dart';

/// A custom [CheckboxListTile] with data from [model]
class TodoItem extends StatelessWidget {
  final TodoModel model;

  const TodoItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      //checkboxShape: const CircleBorder(), //un-comment to make it circular
      title: Text(model.title,
          style: model.isCompleted
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null),
      secondary: PopupMenuButton(
        itemBuilder: (context) {
          return [
            const PopupMenuItem(
              value: 1,
              child: Text('Edit'),
            )
          ];
        },
        onSelected: (value) async {
          var result = await Navigator.of(context).pushNamed(
            TodoFormScreen.route,
            arguments: model,
          );
          if (result != null) {
            context
                .read<HomeBloc>()
                .add(TodoUpdatedEvent(model: result as TodoModel));
          }
        },
      ),
      value: model.isCompleted,
      onChanged: (bool? value) {
        context.read<HomeBloc>().add(ToggleTodoEvent(model: model));
      },
    );
  }
}
