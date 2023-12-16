import 'package:flutter/material.dart';

/// A curved edges [Appbar], with [title], [subtitle] and if back navigation if
/// [automaticallyImplyLeading] is true
class CurvedAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool automaticallyImplyLeading;

  const CurvedAppbar({
    Key? key,
    required this.title,
    this.subtitle,
    this.automaticallyImplyLeading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      foregroundColor: Colors.white,
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Column(
        children: [
          Text(title),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 14.0),
            ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: Container(
          height: 30,
          width: double.infinity,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30.0),
              topLeft: Radius.circular(30.0),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 30);
}
