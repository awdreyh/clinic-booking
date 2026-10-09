import 'package:flutter/material.dart';


import '../user/dashboard.dart';
import 'app_theme.dart';

/// Root shell shown once a user is signed in: bottom navigation between the
/// tea, teaware, log, and profile sections. Tab state is preserved via
/// [IndexedStack] so switching tabs doesn't reset scroll position/forms.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [

    Dashboard(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.espresso,
        indicatorColor: AppColors.accent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined, color: AppColors.textOnDarkMuted),
            selectedIcon: Icon(Icons.local_florist, color: Colors.white),
            label: '茶',
          ),
          NavigationDestination(
            icon: Icon(Icons.coffee_maker_outlined, color: AppColors.textOnDarkMuted),
            selectedIcon: Icon(Icons.coffee_maker, color: Colors.white),
            label: '茶具',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined, color: AppColors.textOnDarkMuted),
            selectedIcon: Icon(Icons.edit_note, color: Colors.white),
            label: '记录',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: AppColors.textOnDarkMuted),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

