import 'package:app/feed/models/feed.dart';
import 'package:app/feed/views/components/feed_image.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/router.dart';
import 'package:app/settings/states/feeds.dart';
import 'package:app/utils/dialog.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_loading_indicator/loading_indicator.dart';

const _validUrl = r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)";

final _formKey = GlobalKey<FormState>();

@RoutePage()
class FeedsSettingsTab extends StatelessWidget {
  const FeedsSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final locals = AppLocalizations.of(context)!;
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
                        padding: EdgeInsets.all(pu2),
                        child: Form(
                          key: _formKey,
                          child: Row(
                            crossAxisAlignment: .center,
                            spacing: pu2,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: cubit.newFeedController,
                                  autofillHints: [AutofillHints.url],
                                  decoration: InputDecoration(label: Text(locals.newFeedUrl)),
                                  validator: (value) {
                                    if (!RegExp(_validUrl).hasMatch(value ?? '')) {
                                      return locals.invalidUrl;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    cubit.addFeed();
                                  }
                                },
                                label: Text(locals.addFeed),
                                icon: Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: .start,
                        spacing: pu2,
                        children: [
                          TextButton.icon(
                            onPressed: () => cubit.exportFeed(),
                            label: Text(locals.export),
                            icon: Icon(Icons.download),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                allowedExtensions: ['opml'],
                                allowMultiple: false,
                                type: FileType.custom,
                              );

                              if (result != null && result.files.isNotEmpty) {
                                final feeds = await cubit.importFeeds(result.files.first.bytes);
                                if (context.mounted && feeds.isNotEmpty) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text(locals.importedNFeeds(feeds.length))));
                                }
                              }
                            },
                            label: Text(locals.import),
                            icon: Icon(Icons.upload),
                          ),
                        ],
                      ),
                      state.feeds.isEmpty
                          ? Expanded(
                              child: Column(
                                crossAxisAlignment: .center,
                                mainAxisAlignment: .center,
                                spacing: pu6,
                                children: [
                                  Icon(Icons.sentiment_neutral_outlined, size: 50),
                                  Text(locals.noFeeds, style: textTheme.bodyLarge),
                                ],
                              ),
                            )
                          : Expanded(
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
                                    subtitle: SelectableText(f.url ?? ''),
                                    trailing: Row(
                                      mainAxisAlignment: .end,
                                      crossAxisAlignment: .center,
                                      mainAxisSize: .min,
                                      children: [
                                        _ErrorButton(feed: f),
                                        IconButton(
                                          onPressed: () {
                                            okCancelDialog(
                                              context,
                                              title: locals.deleteFeed,
                                              content: Text(locals.deleteFeedMessage),
                                              onOk: () => cubit.deleteFeed(f),
                                            );
                                          },
                                          icon: Icon(Icons.delete),
                                        ),
                                      ],
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

class _ErrorButton extends StatelessWidget {
  final Feed feed;

  const _ErrorButton({required this.feed});

  void openErrors(BuildContext context) {
    AutoRouter.of(context).push(FeedErrorsRoute(feed: feed));
  }

  @override
  Widget build(BuildContext context) {
    final device = BreakPoint.get(context);
    final colors = Theme.of(context).colorScheme;

    final locals = AppLocalizations.of(context)!;
    final hasErrors = feed.lastRefreshErrors > 0;
    var icon = Icon(
      hasErrors ? Icons.error_outline : Icons.check,
      color: hasErrors ? colors.error : Colors.lightGreen.withValues(alpha: 0.5),
    );
    return Tooltip(
      message: locals.duringLastRefreshAttempt,
      child: device == .mobile
          ? IconButton(onPressed: () => openErrors(context), icon: icon)
          : TextButton.icon(
              onPressed: () => openErrors(context),
              icon: icon,
              label: Text(
                locals.nErrors(feed.lastRefreshErrors),
                style: TextStyle(color: hasErrors ? colors.error : colors.onSurface.withValues(alpha: 0.5)),
              ),
            ),
    );
  }
}
