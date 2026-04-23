import 'package:flutter/material.dart';

class VerseCard extends StatelessWidget {
  final String reference;
  final String text;

  const VerseCard({super.key, required this.reference, required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(reference, style: t.titleMedium),
        const SizedBox(height: 6),
        Text(text, style: t.bodyLarge),
      ],
    );
  }
}