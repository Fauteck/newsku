import 'package:app/feed/models/feed.dart';
import 'package:app/feed/models/feed_category.dart';
import 'package:app/feed/states/classic_feed.dart';
import 'package:app/feed/views/components/feed_profile_menu.dart';
import 'package:app/feed/views/components/search_result.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/router.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_loading_indicator/loading_indicator.dart';

@RoutePage()
class ClassicFeedScreen extends StatelessWidget {
  const ClassicFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = BreakPoint.get(context) == BreakPoint.mobile;

    return BlocProvider(
      create: (_) => ClassicFeedCubit(),
      child: BlocBuilder<ClassicFeedCubit, ClassicFeedState>(
        builder: (context, state) {
          final cubit = context.read<ClassicFeedCubit>();
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: cubit.refresh,
              child: CustomScrollView(
                controller: cubit.scrollController,
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    title: Text(locals.classicFeedsTitle),
                    actions: isMobile
                        ? null
                        : [
                            IconButton(
                              key: const Key('feeds-button'),
                              onPressed: () => AutoRouter.of(context)
                                  .navigate(const HomeRoute(children: [FeedRoute()])),
                              icon: Icon(Icons.rss_feed, color: colors.primary),
                              tooltip: locals.classicFeedsTitle,
                            ),
                            IconButton(
                              onPressed: () => cubit.refresh(),
                              icon: const Icon(Icons.refresh),
                            ),
                            const FeedProfileMenu(),
                          ],
                  ),
                  SliverToBoxAdapter(
                    child: isMobile
                        ? _ClassicFeedChipFilters(state: state, cubit: cubit)
                        : _ClassicFeedFilterBar(state: state, cubit: cubit),
                  ),
                  if (state.items.isEmpty && !state.loading)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: pu4,
                          children: [
                            Icon(Icons.rss_feed, size: 48, color: colors.secondary),
                            Text(locals.classicFeedsNoItems, style: textTheme.titleMedium),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        return SearchResult(
                          key: ValueKey(state.items[index]),
                          item: state.items[index],
                          fullDate: true,
                          noDimming: true,
                        );
                      },
                    ),
                  if (state.loading)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(pu4),
                          child: SizedBox(width: 50, height: 50, child: LoadingIndicator()),
                        ),
                      ),
                    )
                  else if (state.hasMore)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(pu4),
                          child: FilledButton.tonalIcon(
                            onPressed: cubit.loadMore,
                            label: Text(locals.classicFeedsLoadMore),
                            icon: const Icon(Icons.expand_more),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClassicFeedFilterBar extends StatelessWidget {
  final ClassicFeedState state;
  final ClassicFeedCubit cubit;

  const _ClassicFeedFilterBar({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;

    final visibleFeeds = state.categoryId == null
        ? state.feeds
        : state.feeds.where((f) => f.category?.id == state.categoryId).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pu4, vertical: pu2),
      child: Wrap(
        spacing: pu3,
        runSpacing: pu2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DropdownMenu<ClassicFeedSort>(
            key: const Key('classic-feed-sort'),
            initialSelection: state.sort,
            label: Text(locals.classicFeedsSortLabel),
            onSelected: (value) {
              if (value != null) cubit.setSort(value);
            },
            dropdownMenuEntries: [
              DropdownMenuEntry(
                value: ClassicFeedSort.chronological,
                label: locals.classicFeedsSortChronological,
              ),
              DropdownMenuEntry(
                value: ClassicFeedSort.importance,
                label: locals.classicFeedsSortImportance,
              ),
            ],
          ),
          if (state.categories.isNotEmpty)
            DropdownMenu<String?>(
              key: const Key('classic-feed-category'),
              initialSelection: state.categoryId,
              label: Text(locals.classicFeedsCategoryLabel),
              onSelected: cubit.setCategoryFilter,
              dropdownMenuEntries: <DropdownMenuEntry<String?>>[
                DropdownMenuEntry<String?>(value: null, label: locals.classicFeedsAllCategories),
                ...state.categories
                    .where((c) => c.id != null)
                    .map((FeedCategory c) => DropdownMenuEntry<String?>(value: c.id, label: c.name)),
              ],
            ),
          if (visibleFeeds.isNotEmpty)
            DropdownMenu<String?>(
              key: ValueKey('classic-feed-feed-${state.categoryId}'),
              initialSelection: state.feedId,
              label: Text(locals.classicFeedsFeedLabel),
              onSelected: cubit.setFeedFilter,
              dropdownMenuEntries: <DropdownMenuEntry<String?>>[
                DropdownMenuEntry<String?>(value: null, label: locals.classicFeedsAllFeeds),
                ...visibleFeeds
                    .where((f) => f.id != null)
                    .map((Feed f) => DropdownMenuEntry<String?>(value: f.id, label: f.name ?? f.url ?? '—')),
              ],
            ),
        ],
      ),
    );
  }
}

/// Mobile variant: three compact [ActionChip]s in a horizontally-scrollable row.
/// Each chip opens a bottom sheet with selectable options so the top of the
/// feed stays dedicated to content, not filter controls.
class _ClassicFeedChipFilters extends StatelessWidget {
  final ClassicFeedState state;
  final ClassicFeedCubit cubit;

  const _ClassicFeedChipFilters({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;

    final visibleFeeds = state.categoryId == null
        ? state.feeds
        : state.feeds.where((f) => f.category?.id == state.categoryId).toList();

    final sortLabel = switch (state.sort) {
      ClassicFeedSort.chronological => locals.classicFeedsSortChronological,
      ClassicFeedSort.importance => locals.classicFeedsSortImportance,
    };

    final categoryLabel = state.categoryId == null
        ? locals.classicFeedsAllCategories
        : state.categories
              .firstWhere(
                (c) => c.id == state.categoryId,
                orElse: () => FeedCategory(id: null, name: locals.classicFeedsAllCategories),
              )
              .name;

    final feedLabel = state.feedId == null
        ? locals.classicFeedsAllFeeds
        : (state.feeds
                  .firstWhere(
                    (f) => f.id == state.feedId,
                    orElse: () => Feed(id: null, url: null, name: locals.classicFeedsAllFeeds),
                  )
                  .name ??
              locals.classicFeedsAllFeeds);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: pu3, vertical: pu2),
      child: Row(
        spacing: pu2,
        children: [
          _FilterChip(
            key: const Key('classic-feed-sort'),
            icon: Icons.sort,
            label: sortLabel,
            onTap: () => _openSortSheet(context),
          ),
          if (state.categories.isNotEmpty)
            _FilterChip(
              key: const Key('classic-feed-category'),
              icon: Icons.category_outlined,
              label: categoryLabel,
              onTap: () => _openCategorySheet(context),
              active: state.categoryId != null,
            ),
          if (visibleFeeds.isNotEmpty || state.feedId != null)
            _FilterChip(
              key: const Key('classic-feed-feed'),
              icon: Icons.rss_feed,
              label: feedLabel,
              onTap: () => _openFeedSheet(context, visibleFeeds),
              active: state.feedId != null,
            ),
        ],
      ),
    );
  }

  Future<void> _openSortSheet(BuildContext context) async {
    final locals = AppLocalizations.of(context)!;
    await _showFilterSheet<ClassicFeedSort>(
      context: context,
      title: locals.classicFeedsSortLabel,
      current: state.sort,
      options: [
        (ClassicFeedSort.chronological, locals.classicFeedsSortChronological),
        (ClassicFeedSort.importance, locals.classicFeedsSortImportance),
      ],
      onSelected: cubit.setSort,
    );
  }

  Future<void> _openCategorySheet(BuildContext context) async {
    final locals = AppLocalizations.of(context)!;
    await _showFilterSheet<String?>(
      context: context,
      title: locals.classicFeedsCategoryLabel,
      current: state.categoryId,
      options: [
        (null, locals.classicFeedsAllCategories),
        ...state.categories.where((c) => c.id != null).map((c) => (c.id, c.name)),
      ],
      onSelected: cubit.setCategoryFilter,
    );
  }

  Future<void> _openFeedSheet(BuildContext context, List<Feed> visibleFeeds) async {
    final locals = AppLocalizations.of(context)!;
    await _showFilterSheet<String?>(
      context: context,
      title: locals.classicFeedsFeedLabel,
      current: state.feedId,
      options: [
        (null, locals.classicFeedsAllFeeds),
        ...visibleFeeds.where((f) => f.id != null).map((f) => (f.id, f.name ?? f.url ?? '—')),
      ],
      onSelected: cubit.setFeedFilter,
    );
  }
}

Future<void> _showFilterSheet<T>({
  required BuildContext context,
  required String title,
  required T current,
  required List<(T, String)> options,
  required ValueChanged<T> onSelected,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final textTheme = Theme.of(sheetContext).textTheme;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pu4, vertical: pu2),
                child: Text(title, style: textTheme.titleMedium),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: options
                      .map(
                        (opt) => RadioListTile<T>(
                          title: Text(opt.$2),
                          value: opt.$1,
                          groupValue: current,
                          onChanged: (value) {
                            Navigator.of(sheetContext).pop();
                            onSelected(value as T);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _FilterChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(icon, size: 18, color: active ? colors.onSecondaryContainer : colors.primary),
      label: Text(label, overflow: TextOverflow.ellipsis),
      onPressed: onTap,
      backgroundColor: active ? colors.secondaryContainer : null,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
