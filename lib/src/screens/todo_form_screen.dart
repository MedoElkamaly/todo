import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/src/blocs/todo_form_bloc.dart';
import 'package:todo/src/enums/loading_status.dart';
import 'package:todo/src/events/todo_form_event.dart';
import 'package:todo/src/resources/models/todo_model.dart';
import 'package:todo/src/states/todo_form_state.dart';
import 'package:todo/src/widgets/curved_appbar.dart';

class TodoFormScreen extends StatefulWidget {
  static const String route = '/home/todo_form';

  const TodoFormScreen({super.key});

  @override
  State<StatefulWidget> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  TodoModel? model;
  bool _isCompleted = false;
  late final TextEditingController _titleController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _titleController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      model = args as TodoModel;
      _titleController.text = model!.title;
      _isCompleted = model!.isCompleted;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CurvedAppbar(
        title: 'New task',
        automaticallyImplyLeading: true,
      ),
      body: BlocConsumer<TodoFormBloc, TodoFormState>(
        listener: (context, state) {
          switch (state.status) {
            case LoadingStatus.loading:
              break;
            case LoadingStatus.loaded:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saved successfully'),
                ),
              );
              Navigator.of(context).pop(state.model);
              break;
            case LoadingStatus.error:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                ),
              );
              break;
            case LoadingStatus.initial:
              break;
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      maxLines: 3,
                      enabled: state.status != LoadingStatus.loading,
                      decoration: InputDecoration(
                        hintText: 'Task',
                        labelText: 'Task',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'field is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      enabled: state.status != LoadingStatus.loading,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('set as completed'),
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _isCompleted = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: state.status == LoadingStatus.loading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                model == null
                                    ? context.read<TodoFormBloc>().add(
                                          InsertTodoEvent(
                                            model: TodoModel(
                                                id: 440,
                                                userId: 1,
                                                title: _titleController.text,
                                                isCompleted: _isCompleted),
                                          ),
                                        )
                                    : context.read<TodoFormBloc>().add(
                                          UpdateTodoEvent(
                                            model: model!.copyWith(
                                              title: _titleController.text,
                                              isCompleted: _isCompleted,
                                            ),
                                          ),
                                        );
                              }
                            },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
