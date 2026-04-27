import 'package:app/feed/views/components/feed_profile_menu.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/router.dart';
import 'package:app/stats/states/stats_state.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/app_name.dart';
import 'package:app/utils/views/components/conditional_wrap.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_loading_indicator/loading_indicator.dart';

@RoutePage()
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  // Index of the AI tab inside `AutoTabsRouter.tabBar.routes`.
  static const _aiTabIndex = 2;

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;

    return AutoTabsRouter.tabBar(
      routes: [TagStatsRoute(), FeedStatsRoute(), AiStatsRoute()],
      builder: (context, child, tabController) => Scaffold(
        appBar: AppBar(
          title: AppName(style: Theme.of(context).textTheme.titleMedium),
          automaticallyImplyLeading: false,
          leading: BackButton(
            onPressed: () => AutoRouter.of(context)
                .navigate(const HomeRoute(children: [FeedRoute()])),
          ),
          actions: const [FeedProfileMenu()],
          bottom: TabBar(
            controller: tabController,
            tabs: [
              Tab(text: locals.tags, icon: Icon(Icons.sell)),
              Tab(text: locals.feeds, icon: Icon(Icons.rss_feed)),
              Tab(text: locals.aiTab, icon: Icon(Icons.auto_awesome)),
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
                      return ConditionalWrap(
                        wrapIf: BreakPoint.get(context) == .mobile,
                        wrapper: (child) => Padding(
                          padding: .symmetric(horizontal: pu2),
                          child: child,
                        ),
                        child: AnimatedBuilder(
                          animation: tabController,
                          builder: (context, _) {
                            // The AI tab manages its own loading state via
                            // OpenaiUsageCubit; don't gate it on StatsCubit.
                            if (tabController.index != _aiTabIndex && state.loading) {
                              return Center(child: LoadingIndicator());
                            }
                            return child;
                          },
                        ),
                      );
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
