// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_state.dart';
import '../../widgets/primary_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> doSignIn() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final app = context.read<AppState>();
      await app.auth.signInEmail(email.text.trim(), pass.text);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> doGoogle() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final app = context.read<AppState>();
      await app.auth.signInWithGoogle();
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Welcome back', style: t.titleLarge),
            const SizedBox(height: 6),
            Text('Your journey is private and secure.', style: t.bodyMedium),
            const SizedBox(height: 18),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 10),
            TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            PrimaryButton(text: loading ? 'Signing in...' : 'Sign in', onPressed: loading ? null : doSignIn),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: loading ? null : doGoogle, child: const Text('Continue with Google')),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.go('/sign-up'),
              child: const Text('Create account'),
            ),
            TextButton(
              onPressed: () async {
                if (email.text.trim().isEmpty) return;
                await context.read<AppState>().auth.sendPasswordReset(email.text.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset email sent')));
                }
              },
              child: const Text('Forgot password'),
            ),
          ],
        ),
      ),
    );
  }
}