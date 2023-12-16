import 'package:flutter/material.dart';
import 'package:todo/src/widgets/todo_shimmer_item.dart';

/// List of [TodoShimmerItem] for loading process
class TodoListShimmer extends StatelessWidget {
  const TodoListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(20, (index) => const TodoShimmerItem()),
    );
  }
}
