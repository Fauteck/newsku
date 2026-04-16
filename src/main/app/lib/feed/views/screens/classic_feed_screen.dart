import 'package:app/feed/states/classic_feed.dart';
import 'package:app/feed/views/components/search_result.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/annotations.dart';
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
