import 'dart:io';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3), // Adaptive sidebar background
      body: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(top: Platform.isMacOS ? 28 : 0),
            child: NavigationRail(
              backgroundColor: Colors.transparent,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.piano_outlined),
                  selectedIcon: const Icon(Icons.piano),
                  label: Text(AppStrings.get(context, 'home')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Text(AppStrings.get(context, 'settings')),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
