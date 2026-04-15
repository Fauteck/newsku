import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/services/feed_service.dart';
import 'package:app/feed/states/main_feed.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/utils/states/simple_cubit.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/conditional_wrap.dart';
import 'package:app/utils/views/components/simple_cubit_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ClickableFeedItem extends StatelessWidget {
  final FeedItem item;
  final Widget Function(bool hovered) builder;
  final bool noDimming;

  const ClickableFeedItem({super.key, required this.item, required this.builder, this.noDimming = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;

    return SimpleCubitView<bool>(
      builder: (context, hovered) {
        var currentUser = context.read<IdentityCubit>().currentUser;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (event) => context.read<SimpleCubit<bool>>().setValue(true),
          onExit: (event) => context.read<SimpleCubit<bool>>().setValue(false),

          child: ConditionalWrap(
            wrapIf: item.read,
            wrapper: (child) {
              return !noDimming &&
                      (currentUser?.readItemHandling == .dim || currentUser?.readItemHandling == .unreadFirstThenDim)
                  ? Opacity(opacity: 0.5, child: child)
                  : child;
            },
            wrapElse: (child) => VisibilityDetector(
              key: ValueKey(item.id),
              onVisibilityChanged: (VisibilityInfo info) {
                if (info.visibleFraction >= 0.9) {
                  context.read<MainFeedCubit>().readItem(item.id);
                }
              },
              child: child,
            ),
            child: Dismissible(
              key: ValueKey('swipe-${item.id}'),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  context.read<MainFeedCubit>().readItem(item.id);
                } else if (direction == DismissDirection.endToStart) {
                  context.read<MainFeedCubit>().toggleSave(item.id ?? '');
                }
                return false;
              },
              background: Container(
                color: colors.primaryContainer,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: pu6),
                child: Row(
                  spacing: pu2,
                  children: [
                    Icon(Icons.check_circle_outline, color: colors.onPrimaryContainer),
                    Text(locals.swipeToRead, style: TextStyle(color: colors.onPrimaryContainer)),
                  ],
                ),
              ),
              secondaryBackground: Container(
                color: colors.secondaryContainer,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: pu6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: pu2,
                  children: [
                    Text(
                      item.saved ? locals.unsaveArticle : locals.saveArticle,
                      style: TextStyle(color: colors.onSecondaryContainer),
                    ),
                    Icon(
                      item.saved ? Icons.bookmark : Icons.bookmark_border,
                      color: colors.onSecondaryContainer,
                    ),
                  ],
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  FeedService(serverUrl!).click(item.id ?? '');
                  launchUrl(Uri.parse(item.url!));
                },
                child: builder(hovered),
              ),
            ),
          ),
        );
      },
      initialValue: false,
    );
  }
}
