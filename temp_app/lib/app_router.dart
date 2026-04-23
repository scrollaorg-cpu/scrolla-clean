// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scrolla/screens/bible/bible_screen.dart';

import 'state/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/setup/personalization_screen.dart';
import 'screens/shell/app_shell.dart';
import 'screens/community/create_post_screen.dart';
import 'screens/community/group_detail_screen.dart';
import 'screens/settings/settings_screen.dart';

GoRouter buildRouter(AppState appState) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: appState,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      GoRoute(
        path: '/sign-in',
        name: 'signin',
        builder: (_, __) => const SignInScreen(),
      ),

      GoRoute(
        path: '/sign-up',
        name: 'signup',
        builder: (_, __) => const SignUpScreen(),
      ),

      GoRoute(
        path: '/setup',
        name: 'setup',
        builder: (_, __) => const PersonalizationScreen(),
      ),

      GoRoute(
        path: '/app',
        name: 'app',
        builder: (_, __) => const AppShell(),
      ),

      // ✅ Bible route
      GoRoute(
        path: '/bible',
        name: 'bible',
        builder: (_, __) => const BibleScreen(),
      ),

      GoRoute(
        path: '/create-post',
        name: 'createPost',
        builder: (_, __) => const CreatePostScreen(),
      ),

      GoRoute(
        path: '/groups/:id',
        name: 'group',
        builder: (_, state) =>
            GroupDetailScreen(groupId: state.pathParameters['id']!),
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // 1) Bootstrapping: stay on splash
      if (!appState.initialized) {
        return loc == '/splash' ? null : '/splash';
      }

      final loggedIn = appState.auth.currentUser != null;

      // 2) Logged OUT: allow onboarding + auth screens
      if (!loggedIn) {
        if (loc == '/onboarding' || loc == '/sign-in' || loc == '/sign-up') return null;
        return '/onboarding';
      }

      // 3) Logged IN: enforce setup if missing
      final me = appState.me;
      final needsSetup = (me?.focus == null || (me!.focus ?? '').isEmpty);

      if (needsSetup) {
        return loc == '/setup' ? null : '/setup';
      }

      // 4) Logged IN + setup complete: keep away from public screens
      if (loc == '/onboarding' || loc == '/sign-in' || loc == '/sign-up' || loc == '/splash' || loc == '/setup') {
        return '/app';
      }

      return null;
    },
  );
}