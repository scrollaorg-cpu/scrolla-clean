import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int index = 0;

  void next() {
    if (index < 2) {
      _pc.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pc,
                onPageChanged: (i) => setState(() => index = i),
                children: const [
                  _Page(
                    title: 'Stay focused. Grow in faith.',
                    subtitle: 'Your all-in-one Christian productivity space.',
                    icon: Icons.favorite_outline,
                  ),
                  _Page(
                    title: 'Faith × Productivity × Fellowship',
                    subtitle: 'Journal, plan, pray—and connect with believers.',
                    icon: Icons.grid_view_rounded,
                    bullets: [
                      '📖 Faith journaling',
                      '✅ Smart productivity',
                      '🤝 Christian community',
                    ],
                  ),
                  _Page(
                    title: 'Start your Scrolla journey',
                    subtitle: 'Create an account or sign in to continue.',
                    icon: Icons.rocket_launch_outlined,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (index < 2)
                    Row(
                      children: [
                        Expanded(child: PrimaryButton(text: 'Next →', onPressed: next)),
                      ],
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(child: PrimaryButton(text: 'Create account', onPressed: () => context.go('/sign-up'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextButton(onPressed: () => context.go('/sign-in'), child: Text('Sign in', style: t.textTheme.labelLarge)),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String>? bullets;

  const _Page({required this.title, required this.subtitle, required this.icon, this.bullets});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          Icon(icon, size: 44),
          const SizedBox(height: 18),
          Text(title, style: t.titleLarge),
          const SizedBox(height: 10),
          Text(subtitle, style: t.bodyLarge),
          const SizedBox(height: 18),
          if (bullets != null)
            ...bullets!.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(b, style: t.bodyLarge),
                )),
        ],
      ),
    );
  }
}