import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const Spacer(),

              // Logo + Brand
              Column(
                children: [
                  Image.asset(
                    'assets/images/scrolla_logo.png',
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('LOGO FAILED TO LOAD', style: TextStyle(color: Colors.red));
                    },
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 14),
                  Text('Scrolla', style: t.titleLarge),
                ],
              ),

              const Spacer(),

              // Loading bar (animated)
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 6,
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (_, __) => LinearProgressIndicator(
                      value: 0.25 + (_c.value * 0.75),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text('Focus, Faith & Fellowship', style: t.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}