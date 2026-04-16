import 'package:app/router.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    if (BreakPoint.get(context) != BreakPoint.mobile) {
      return const SizedBox.shrink();
    }

    final router = AutoRouter.of(context);

    int selected;
    if (router.isRouteActive(StatsRoute.name)) {
      selected = 1;
    } else if (router.isRouteActive(SettingsRoute.name)) {
      selected = 2;
    } else {
      selected = 0;
    }

    return NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (i) {
        if (i == selected) return;
        router.popUntilRouteWithName(HomeRoute.name);
        switch (i) {
          case 1:
            router.push(const StatsRoute());
            break;
          case 2:
            router.push(const SettingsRoute());
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.article_outlined),
          selectedIcon: Icon(Icons.article),
          label: 'Magazin',
        ),
        NavigationDestination(
          icon: Icon(Icons.insights_outlined),
          selectedIcon: Icon(Icons.insights),
          label: 'Stats',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Optionen',
        ),
      ],
    );
  }
}
