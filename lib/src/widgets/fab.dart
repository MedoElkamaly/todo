import 'package:flutter/material.dart';

/// A custom [FloatingActionButton] with [AnimatedScale] if [isVisible] is true
class Fab extends StatelessWidget {
  final bool isVisible;
  final Function() onPress;

  const Fab({super.key, required this.isVisible, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: onPress,
        tooltip: 'Insert new',
        child: const Icon(Icons.add),
      ),
    );
  }
}
