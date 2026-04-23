import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/app_user.dart';

class AppState extends ChangeNotifier {
  final AuthService auth = AuthService();
  final FirestoreService db = FirestoreService();

  AppUser? me;
  bool initialized = false;

  ThemeMode themeMode = ThemeMode.system;
  ThemeData lightTheme = AppTheme.light();
  ThemeData darkTheme = AppTheme.dark();

  StreamSubscription<AppUser>? _meSub;
  StreamSubscription? _authSub;

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode') ?? 'system';
    themeMode = _parseThemeMode(savedTheme);

    // ✅ Resolve initial auth state immediately
    final user = auth.currentUser;

    if (user == null) {
      me = null;
      initialized = true;
      notifyListeners();
    } else {
      // Ensure user exists, then start listening to user doc
      await db.ensureUser(user.uid, user.displayName ?? 'User', user.email ?? '');
      _startUserListener(user.uid);
      initialized = true;
      notifyListeners();
    }

    // ✅ Listen for auth changes
    _authSub?.cancel();
    _authSub = auth.onAuthStateChanged.listen((user) async {
      _meSub?.cancel();
      _meSub = null;

      if (user == null) {
        me = null;
        initialized = true;
        notifyListeners();
        return;
      }

      await db.ensureUser(user.uid, user.displayName ?? 'User', user.email ?? '');
      _startUserListener(user.uid);

      initialized = true;
      notifyListeners();
    });
  }

  void _startUserListener(String uid) {
    _meSub?.cancel();
    _meSub = db.watchUser(uid).listen((u) async {
      me = u;

      // Keep theme in sync if it exists on the user doc
      final prefs = await SharedPreferences.getInstance();
      final raw = (u.themeMode);
      themeMode = _parseThemeMode(raw);
      await prefs.setString('themeMode', raw);

      notifyListeners();
    });
  }

  ThemeMode _parseThemeMode(String raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode);
    themeMode = _parseThemeMode(mode);

    if (me != null) {
      await db.updateUserTheme(me!.uid, mode);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _meSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  void applySetupLocal({required String focus, required List<String> interests, required Map<String, String> reminders}) {}
}