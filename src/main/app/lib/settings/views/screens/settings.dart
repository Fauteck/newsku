import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.tabBar(routes: [FeedsSettingsRoute(), GeneralSettingsRoute()],
      builder: (context, child, tabController)  {
        return Scaffold(
          appBar: AppBar(title: Text('Settings'),
            actions: [
              TextButton.icon(onPressed: () => getIt.get<IdentityCubit>().logout(), label: Text('Logout'), icon: Icon(Icons.logout),)
            ],
            bottom: TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: 'Feeds', icon: Icon(Icons.rss_feed)),
                Tab(text: 'General', icon: Icon(Icons.settings)),
              ],
            ),
          ),
          body: child
        );
      }
    );
  }
}
