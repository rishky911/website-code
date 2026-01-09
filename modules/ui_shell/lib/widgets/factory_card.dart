import 'package:flutter/material.dart';

class FactoryCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const FactoryCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    // Styling handled by Theme.of(context).cardTheme
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
