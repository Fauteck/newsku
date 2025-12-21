import 'package:app/l10n/app_localizations.dart';
import 'package:app/router.dart';
import 'package:app/stats/states/stats_state.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_loading_indicator/loading_indicator.dart';

@RoutePage()
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;

    return AutoTabsRouter.tabBar(
      routes: [TagStatsRoute(), FeedStatsRoute()],
      builder: (context, child, tabController) => Scaffold(
        appBar: AppBar(
          title: Text(locals.stats),
          bottom: TabBar(
            controller: tabController,
            tabs: [
              Tab(text: locals.tags, icon: Icon(Icons.sell)),
              Tab(text: locals.feeds, icon: Icon(Icons.rss_feed)),
            ],
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: BreakPoint.tablet.maxWidth),
              child: BlocProvider(
                create: (context) => StatsCubit(StatsState()),
                child: ErrorHandler<StatsCubit, StatsState>(
                  child: BlocBuilder<StatsCubit, StatsState>(
                    builder: (context, state) {
                      if (state.loading) {
                        return Center(child: LoadingIndicator());
                      } else {
                        return child;
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
