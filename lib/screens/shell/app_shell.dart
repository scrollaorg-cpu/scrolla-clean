import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../journal/journal_screen.dart';
import '../focus/focus_screen.dart';
import '../community/community_screen.dart';
import '../profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int i = 0;

  final pages = const [
    HomeScreen(),
    JournalScreen(),
    FocusScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.edit_note_rounded), label: 'Journal'),
          NavigationDestination(icon: Icon(Icons.checklist_rounded), label: 'Focus'),
          NavigationDestination(icon: Icon(Icons.groups_rounded), label: 'Community'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}