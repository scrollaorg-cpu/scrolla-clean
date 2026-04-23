import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;

  const ResponsiveScaffold({
    super.key,
    required this.mobile,
    this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Tablet breakpoint
    if (width >= 768 && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}