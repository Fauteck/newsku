import 'package:app/feed/views/components/feed_image.dart';
import 'package:app/settings/states/feeds.dart';
import 'package:app/utils/dialog.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_loading_indicator/loading_indicator.dart';

@RoutePage()
class FeedsSettingsTab extends StatelessWidget {
  const FeedsSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedsSettingsCubit(FeedsSettingsState()),
      child: ErrorHandler<FeedsSettingsCubit, FeedsSettingsState>(
        child: BlocBuilder<FeedsSettingsCubit, FeedsSettingsState>(
          builder: (context, state) {
            var cubit = context.read<FeedsSettingsCubit>();
            return state.loading
                ? Center(child: SizedBox(width: 50, height: 50, child: LoadingIndicator()))
                : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cubit.newFeedController,
                              autofillHints: [AutofillHints.url],
                              decoration: InputDecoration(label: Text('New feed Url')),
                            ),
                          ),
                          FilledButton.tonalIcon(onPressed: () => cubit.addFeed(), label: Text('Add Feed'), icon: Icon(Icons.add)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.feeds.length,
                        itemBuilder: (context, index) {
                          final f = state.feeds[index];

                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: .circular(50),
                              child: FeedImage(item: f, width: 50, height: 50),
                            ),
                            title: Text(f.name ?? ''),
                            subtitle: Text(f.url ?? ''),
                            trailing: IconButton(
                              onPressed: () {
                                okCancelDialog(context, title: 'Delete feed ?', content: Text('This will delete the feed and all its articles.'), onOk: () => cubit.deleteFeed(f));
                              },
                              icon: Icon(Icons.delete),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
          },
        ),
      ),
    );
  }
}
