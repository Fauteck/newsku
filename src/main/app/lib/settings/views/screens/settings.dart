import 'package:app/identity/states/identity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/main.dart';
import 'package:app/settings/views/tabs/feeds.dart';
import 'package:app/settings/views/tabs/general.dart';
import 'package:app/settings/views/tabs/info.dart';
import 'package:app/settings/views/tabs/layout.dart';
import 'package:app/settings/views/tabs/user.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/views/components/mobile_bottom_nav.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;
    final isMobile = BreakPoint.get(context) == BreakPoint.mobile;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(locals.settings),
          actions: [
            TextButton.icon(
              onPressed: () => getIt.get<IdentityCubit>().logout(),
              label: Text(locals.logout),
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: locals.feeds, icon: const Icon(Icons.rss_feed)),
              Tab(text: locals.darstellung, icon: const Icon(Icons.grid_view_sharp)),
              Tab(text: locals.user, icon: const Icon(Icons.person)),
              Tab(text: locals.about, icon: const Icon(Icons.info_outline)),
            ],
          ),
        ),
        bottomNavigationBar: isMobile ? const MobileBottomNav() : null,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: BreakPoint.tablet.maxWidth),
              child: TabBarView(
                children: [
                  const FeedsSettingsTab(),
                  const _DarstellungTab(),
                  const UserSettingsTab(),
                  const InfoTab(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DarstellungTab extends StatelessWidget {
  const _DarstellungTab();

  @override
  Widget build(BuildContext context) {
    // The upper (general) section renders at its natural height so it's fully
    // visible without a nested scrollbar. Only the layout editor keeps its own
    // scrollable area because of drag-and-drop.
    return const Column(
      children: [
        GeneralSettingsTab(),
        Divider(height: 1),
        Expanded(child: LayoutSettingsTab()),
      ],
    );
  }
}
