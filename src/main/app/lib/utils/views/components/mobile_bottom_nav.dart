import 'package:app/identity/states/identity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});

  void _showMoreSheet(BuildContext context) {
    final router = AutoRouter.of(context);
    final locals = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(locals.settings),
              onTap: () {
                Navigator.pop(sheetContext);
                router.push(const SettingsRoute());
              },
            ),
            if (config?.freshRssUrl != null && config!.freshRssUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: Text(locals.openInFreshRss),
                onTap: () {
                  Navigator.pop(sheetContext);
                  launchUrl(Uri.parse(config!.freshRssUrl!));
                },
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(locals.logout),
              onTap: () => getIt.get<IdentityCubit>().logout(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (BreakPoint.get(context) != BreakPoint.mobile) {
      return const SizedBox.shrink();
    }

    final router = AutoRouter.of(context);

    final int selected;
    if (router.isRouteActive(StatsRoute.name)) {
      selected = 1;
    } else {
      selected = 0;
    }

    return NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (i) {
        if (i == 2) {
          _showMoreSheet(context);
          return;
        }
        if (i == selected) return;
        router.popUntilRouteWithName(HomeRoute.name);
        if (i == 1) {
          router.push(const StatsRoute());
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
          icon: Icon(Icons.more_horiz),
          label: 'Mehr',
        ),
      ],
    );
  }
}
