import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/ui.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: navigationShell,
        bottomNavigationBar: PPBottomNavBar(
          index: navigationShell.currentIndex,
          onChanged: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      );
}
