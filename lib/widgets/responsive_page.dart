import 'package:flutter/material.dart';

class ResponsivePage extends StatelessWidget {
  final Widget child;
  final double maxContentWidth;
  final EdgeInsetsGeometry padding;

  const ResponsivePage({
    super.key,
    required this.child,
    this.maxContentWidth = 700,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 768;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? maxContentWidth : constraints.maxWidth,
            ),
            child: Padding(
              padding: padding,
              child: child,
            ),
          )
        );
      },
    );
  }
}
         