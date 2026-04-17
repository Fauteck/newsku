import 'package:app/identity/states/identity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:app/user/views/components/user_profile_picture.dart';
import 'package:app/utils/views/components/conditional_wrap.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// Profile dropdown for the feed-related AppBars.
///
/// Contains: Stats, Settings (unless demo), GReader (if configured), Logout.
/// Does NOT contain Feeds — that's a top-level action next to search now.
class FeedProfileMenu extends StatelessWidget {
  final int errorCount;
  final VoidCallback? onSettingsClosed;

  const FeedProfileMenu({super.key, this.errorCount = 0, this.onSettingsClosed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;
    final demoMode = context.read<IdentityCubit>().state.config?.demoMode ?? false;
    final gReaderUrl = config?.gReaderUrl;

    return MenuAnchor(
      key: const Key('profile-button'),
      builder: (context, controller, child) => IconButton(
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        icon: const UserProfilePicture(),
      ),
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.show_chart),
          onPressed: () => AutoRouter.of(context).push(const StatsRoute()),
          child: Text(locals.stats),
        ),
        if (!demoMode)
          MenuItemButton(
            key: const Key('settings-button'),
            leadingIcon: ConditionalWrap(
              wrapIf: errorCount > 0,
              wrapper: (child) => Badge(
                offset: const Offset(5, 0),
                backgroundColor: colors.errorContainer,
                textColor: colors.error,
                label: Text('$errorCount'),
                child: child,
              ),
              child: const Icon(Icons.settings),
            ),
            onPressed: () => AutoRouter.of(context)
                .push(const SettingsRoute())
                .then((_) => onSettingsClosed?.call()),
            child: Text(locals.settings),
          ),
        if (gReaderUrl != null && gReaderUrl.isNotEmpty) ...[
          const Divider(),
          MenuItemButton(
            leadingIcon: const Icon(Icons.open_in_new),
            onPressed: () => launchUrl(Uri.parse(gReaderUrl)),
            child: Text(locals.openInGreader),
          ),
        ],
        const Divider(),
        MenuItemButton(
          leadingIcon: const Icon(Icons.logout),
          onPressed: () => getIt.get<IdentityCubit>().logout(),
          child: Text(locals.logout),
        ),
      ],
    );
  }
}
