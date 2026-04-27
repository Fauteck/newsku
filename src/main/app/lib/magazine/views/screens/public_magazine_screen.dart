import 'dart:math';

import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/states/main_feed.dart';
import 'package:app/feed/views/components/date_bar.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/magazine/services/magazine_tab_service.dart';
import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

@RoutePage()
class PublicMagazineScreen extends StatefulWidget {
  final String tabId;

  const PublicMagazineScreen({super.key, @PathParam('tabId') required this.tabId});

  @override
  State<PublicMagazineScreen> createState() => _PublicMagazineScreenState();
}

class _PublicMagazineScreenState extends State<PublicMagazineScreen> {
  List<FeedItem> _items = [];
  List<LayoutBlock> _layout = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final url = serverUrl;
      if (url == null) {
        setState(() {
          _loading = false;
          _error = 'Server-URL nicht konfiguriert';
        });
        return;
      }
      final service = PublicMagazineService(url);
      final layoutFuture = service.getTabLayout(widget.tabId);
      final itemsFuture = service.getItems(widget.tabId);
      final layout = await layoutFuture;
      final items = await itemsFuture;
      if (!mounted) return;
      setState(() {
        _layout = layout;
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  List<Widget> _buildLayoutSlivers(BuildContext context, double padding) {
    final List<Widget> slivers = [];
    final List<FeedItem> items = List.from(_items);

    for (final (index, block) in _layout.indexed) {
      if (items.isEmpty) break;

      final settings = block.settings ?? block.type.defaultSettings;
      List<FeedItem> blockItems;
      if (index == _layout.length - 1) {
        if (block.type.fixedSize || settings.lastBlockShowAll) {
          blockItems = List.from(items);
        } else {
          final size = settings.items ?? 0;
          blockItems = items
              .where((i) => settings.categoryId == null || i.feed?.category?.id == settings.categoryId)
              .take(size > 0 ? size : items.length)
              .toList();
        }
      } else {
        final size = block.type.fixedItemSize ?? settings.items ?? 0;
        blockItems = items
            .where((i) => settings.categoryId == null || i.feed?.category?.id == settings.categoryId)
            .take(size)
            .toList();
      }

      if (blockItems.isNotEmpty) {
        slivers.add(block.type.getSliver(context: context, items: blockItems, block: block));
      }
      for (final element in blockItems) {
        items.remove(element);
      }
    }

    final referenceDate = _items.isNotEmpty
        ? DateTime.fromMillisecondsSinceEpoch(_items.first.timeCreated)
        : DateTime.now();

    for (int i = 0; i < slivers.length; i++) {
      slivers[i] = SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: padding + pu4),
        sliver: SliverStickyHeader.builder(
          builder: (context, state) => DateBar(date: referenceDate, isPinned: state.isPinned, isFirst: i == 0),
          sliver: slivers[i],
        ),
      );
    }

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => MainFeedCubit(
        MainFeedState(currentTime: DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999)),
        publicMode: true,
      ),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double padding = max(0, (constraints.maxWidth - BreakPoint.desktop.maxWidth) / 2);

            final body = _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(pu4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: colors.error),
                              const SizedBox(height: 16),
                              Text(_error!, style: TextStyle(color: colors.error)),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () {
                                  setState(() {
                                    _loading = true;
                                    _error = null;
                                  });
                                  _load();
                                },
                                child: const Text('Erneut versuchen'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _items.isEmpty
                        ? Center(
                            child: Text(
                              'Keine Artikel vorhanden',
                              style: textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: CustomScrollView(
                              slivers: [
                                SliverAppBar(
                                  floating: true,
                                  snap: true,
                                  elevation: 0,
                                  scrolledUnderElevation: 0,
                                  automaticallyImplyLeading: false,
                                  title: const Text('Feedteck'),
                                  actions: [
                                    BlocBuilder<IdentityCubit, IdentityState>(
                                      bloc: getIt.get<IdentityCubit>(),
                                      builder: (context, state) {
                                        if (state.isLoggedIn) return const SizedBox.shrink();
                                        return TextButton(
                                          onPressed: () => AutoRouter.of(context).replaceAll([LandingRoute()]),
                                          child: const Text('Anmelden'),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                ..._buildLayoutSlivers(context, padding),
                                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                              ],
                            ),
                          );

            return body;
          },
        ),
      ),
    );
  }
}
