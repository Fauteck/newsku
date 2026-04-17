import 'package:app/identity/states/identity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileBottomNav extends StatefulWidget {
  const MobileBottomNav({super.key});

  @override
  State<MobileBottomNav> createState() => _MobileBottomNavState();
}

class _MobileBottomNavState extends State<MobileBottomNav> {
  StackRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = AutoRouter.of(context);
    if (!identical(router, _router)) {
      _router?.removeListener(_onRouteChanged);
      _router = router;
      _router?.addListener(_onRouteChanged);
    }
  }

  @override
  void dispose() {
    _router?.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (mounted) setState(() {});
  }

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
            if (config?.gReaderUrl != null && config!.gReaderUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: Text(locals.openInGreader),
                onTap: () {
                  Navigator.pop(sheetContext);
                  launchUrl(Uri.parse(config!.gReaderUrl!));
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
      selected = 2;
    } else if (router.isRouteActive(ClassicFeedRoute.name)) {
      selected = 1;
    } else if (router.isRouteActive(FeedRoute.name)) {
      selected = 0;
    } else {
      selected = -1;
    }

    return NavigationBar(
      selectedIndex: selected >= 0 ? selected : 0,
      onDestinationSelected: (i) {
        if (i == 3) {
          _showMoreSheet(context);
          return;
        }
        if (i == selected) return;
        switch (i) {
          case 0:
            router.navigate(const HomeRoute(children: [FeedRoute()]));
            break;
          case 1:
            router.navigate(const HomeRoute(children: [ClassicFeedRoute()]));
            break;
          case 2:
            router.navigate(const StatsRoute());
            break;
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.article_outlined),
          selectedIcon: const Icon(Icons.article),
          label: 'Magazin',
        ),
        NavigationDestination(
          icon: const Icon(Icons.rss_feed_outlined),
          selectedIcon: const Icon(Icons.rss_feed),
          label: 'Feeds',
        ),
        NavigationDestination(
          icon: const Icon(Icons.insights_outlined),
          selectedIcon: const Icon(Icons.insights),
          label: 'Stats',
        ),
        NavigationDestination(
          icon: const Icon(Icons.more_horiz),
          label: 'Mehr',
        ),
      ],
    );
  }
}
