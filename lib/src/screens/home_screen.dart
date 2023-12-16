import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/src/blocs/home_bloc.dart';
import 'package:todo/src/enums/loading_status.dart';
import 'package:todo/src/events/home_event.dart';
import 'package:todo/src/screens/todo_form_screen.dart';
import 'package:todo/src/states/home_state.dart';
import 'package:todo/src/widgets/curved_appbar.dart';
import 'package:todo/src/widgets/fab.dart';
import 'package:todo/src/widgets/todo_list.dart';
import 'package:todo/src/widgets/todo_list_shimmer.dart';

class HomeScreen extends StatefulWidget {
  static const String route = '/home';

  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _controller = ScrollController();
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_bottomRefreshScrollListener);
    _controller.addListener(_fabScrollListener);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Listens to [ScrollController] and detect when the scrolling reached the bottom
  /// then calls the BloC to get a new page
  void _bottomRefreshScrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent * 1 &&
        !_controller.position.outOfRange) {
      context.read<HomeBloc>().add(GetTodosEvent());
    }
  }

  /// Listens to [ScrollController] and detect if the scrolling is upwards then it
  /// will show the [FloatingActionButton], if it is downwards it will hide the
  /// [FloatingActionButton]
  void _fabScrollListener() {
    if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isFabVisible == true) {
        setState(() {
          _isFabVisible = false;
        });
      }
    } else {
      if (_controller.position.userScrollDirection == ScrollDirection.forward) {
        if (_isFabVisible == false) {
          setState(() {
            _isFabVisible = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CurvedAppbar(title: 'Tasks'),
      floatingActionButton: Fab(
        isVisible: _isFabVisible,
        onPress: () async {
          var result = await Navigator.of(context).pushNamed(
            TodoFormScreen.route,
          );
          if (result != null) {
            context.read<HomeBloc>().add(ReloadTodosEvent());
          }
        },
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (BuildContext context, HomeState state) {
          if (state.status == LoadingStatus.error && state.error.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              ),
            );
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case LoadingStatus.loading:
              return const SizedBox.shrink();
            case LoadingStatus.loaded:
            case LoadingStatus.error:
              return TodoList(
                controller: _controller,
                lastPage: state.lastPage,
                todos: state.todos,
              );
            case LoadingStatus.initial:
              return const TodoListShimmer();
          }
        },
      ),
    );
  }
}
