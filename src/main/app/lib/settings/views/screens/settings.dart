import 'package:app/ai/states/ai_prompts.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/main.dart';
import 'package:app/settings/views/tabs/ai.dart';
import 'package:app/settings/views/tabs/ai_activity_log.dart';
import 'package:app/settings/views/tabs/feeds.dart';
import 'package:app/settings/views/tabs/info.dart';
import 'package:app/settings/views/tabs/layout.dart';
import 'package:app/settings/views/tabs/user.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/views/components/mobile_bottom_nav.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;
    final isMobile = BreakPoint.get(context) == BreakPoint.mobile;
    return BlocProvider(
      create: (_) => AiPromptsCubit(const AiPromptsState()),
      child: DefaultTabController(
        length: 6,
        child: Scaffold(
          appBar: AppBar(
            title: Text(locals.settings),
            automaticallyImplyLeading: false,
            leading: !isMobile
                ? BackButton(onPressed: () => AutoRouter.of(context).maybePop())
                : null,
            actions: [
              TextButton.icon(
                onPressed: () => getIt.get<IdentityCubit>().logout(),
                label: Text(locals.logout),
                icon: const Icon(Icons.logout),
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: locals.user, icon: const Icon(Icons.person)),
                Tab(text: locals.layout, icon: const Icon(Icons.view_module_outlined)),
                Tab(text: locals.feeds, icon: const Icon(Icons.rss_feed)),
                Tab(text: locals.aiTab, icon: const Icon(Icons.auto_awesome)),
                Tab(text: locals.aiLog, icon: const Icon(Icons.history)),
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
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const UserSettingsTab(),
                    const LayoutSettingsTab(),
                    const FeedsSettingsTab(),
                    const AiSettingsTab(),
                    const AiActivityLogTab(),
                    const InfoTab(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
