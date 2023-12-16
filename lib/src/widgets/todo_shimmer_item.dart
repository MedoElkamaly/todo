import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A custom [Shimmer] item with [CheckboxListTile]
class TodoShimmerItem extends StatelessWidget {
  const TodoShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Container(
          color: Colors.black,
          height: 30,
          width: double.infinity,
        ),
        value: true,
        onChanged: (bool? value) {},
      ),
    );
  }
}
