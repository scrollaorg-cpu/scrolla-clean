import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'state/app_state.dart';
import 'app_router.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.instance.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..bootstrap(),
      child: const ScrollaApp(),
    ),
  );
}

class ScrollaApp extends StatefulWidget {
  const ScrollaApp({super.key});

  @override
  State<ScrollaApp> createState() => _ScrollaAppState();
}

class _ScrollaAppState extends State<ScrollaApp> {
  late final appState = context.read<AppState>();
  late final router = buildRouter(appState); // ✅ create ONCE

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Scrolla',
      theme: s.lightTheme,
      darkTheme: s.darkTheme,
      themeMode: s.themeMode,
      routerConfig: router, // ✅ stable router instance
    );
  }
}