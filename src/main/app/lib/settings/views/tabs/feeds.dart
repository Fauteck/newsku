import 'package:app/l10n/app_localizations.dart';
import 'package:app/settings/states/feeds.dart';
import 'package:app/settings/views/components/feed_category.dart';
import 'package:app/sync/models/sync_status_response.dart';
import 'package:app/sync/services/sync_status_service.dart';
import 'package:app/utils/dialog.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:material_loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

Future<SyncStatusResponse?> _pollSyncStatus(String serverUrl) async {
  final service = SyncStatusService(serverUrl);
  for (int i = 0; i < 20; i++) {
    try {
      final status = await service.getStatus();
      if (status.isTerminal) return status;
    } catch (_) {
      // Transient polling failures are non-fatal: retry on next tick.
    }
    await Future.delayed(const Duration(seconds: 3));
  }
  try {
    return await service.getStatus();
  } catch (_) {
    return null;
  }
}

const _validUrl = r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)";

final _formKey = GlobalKey<FormState>();

@RoutePage()
class FeedsSettingsTab extends StatelessWidget {
  const FeedsSettingsTab({super.key});

  Future<void> addCategory(BuildContext context) async {
    final locals = AppLocalizations.of(context)!;
    String? name = await showTextInputDialog(context, locals.addCategory);

    if (context.mounted && name != null) {
      context.read<FeedsSettingsCubit>().addFeedCategory(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;
    final gReaderActive = config?.gReaderUrl != null ||
        (identityCubit.currentUser?.gReaderUrl?.isNotEmpty ?? false);

    return BlocProvider(
      create: (context) => FeedsSettingsCubit(FeedsSettingsState()),
      child: ErrorHandler<FeedsSettingsCubit, FeedsSettingsState>(
        child: BlocBuilder<FeedsSettingsCubit, FeedsSettingsState>(
          builder: (context, state) {
            var cubit = context.read<FeedsSettingsCubit>();

            // Auto-sync GReader feeds once on first open if the local cache is empty.
            if (gReaderActive &&
                !state.loading &&
                !state.greaderSyncAttempted &&
                state.feeds.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) => cubit.syncGreader());
            }

            return state.loading
                ? Center(child: SizedBox(width: 50, height: 50, child: LoadingIndicator()))
                : Column(
                    children: [
                      if (gReaderActive) ...[
                        Padding(
                          padding: EdgeInsets.all(pu3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: pu2,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => launchUrl(Uri.parse(config!.gReaderUrl!)),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: pu4, vertical: pu3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: colors.secondaryContainer,
                                  ),
                                  child: Row(
                                    spacing: pu3,
                                    children: [
                                      Icon(Icons.info_outline, color: colors.onSecondaryContainer),
                                      Expanded(
                                        child: Text(
                                          locals.greaderManagedFeeds,
                                          style: textTheme.bodyMedium?.copyWith(color: colors.onSecondaryContainer),
                                        ),
                                      ),
                                      Icon(Icons.open_in_new, color: colors.onSecondaryContainer),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FilledButton.tonalIcon(
                                  onPressed: state.loading
                                      ? null
                                      : () async {
                                          final messenger = ScaffoldMessenger.of(context);
                                          messenger.hideCurrentSnackBar();
                                          messenger.showSnackBar(SnackBar(
                                            content: Text(locals.syncing),
                                            duration: const Duration(minutes: 2),
                                          ));
                                          await cubit.syncGreader();
                                          if (!context.mounted) return;
                                          final status = await _pollSyncStatus(serverUrl!);
                                          if (!context.mounted) return;
                                          messenger.hideCurrentSnackBar();
                                          if (status == null) {
                                            messenger.showSnackBar(SnackBar(
                                              content: Text(locals.syncCompleted(0)),
                                            ));
                                          } else if (status.status == SyncStatus.failed) {
                                            messenger.showSnackBar(SnackBar(
                                              content: Text(locals.syncFailedReason(
                                                  status.errorMessage ?? '—')),
                                              backgroundColor: colors.errorContainer,
                                            ));
                                          } else {
                                            messenger.showSnackBar(SnackBar(
                                              content: Text(
                                                  locals.syncCompleted(status.itemsAdded ?? 0)),
                                            ));
                                          }
                                        },
                                  icon: const Icon(Icons.sync),
                                  label: Text(locals.syncNow),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (!gReaderActive) ...[
                        Padding(
                          padding: EdgeInsets.all(pu2),
                          child: Form(
                            key: _formKey,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: pu2,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: cubit.newFeedController,
                                    autofillHints: const [AutofillHints.url],
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
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: pu2,
                          children: [
                            TextButton.icon(
                              onPressed: () => addCategory(context),
                              label: Text(locals.addCategory),
                              icon: const Icon(Icons.add),
                            ),
                            TextButton.icon(
                              onPressed: () => cubit.exportFeed(),
                              label: Text(locals.export),
                              icon: const Icon(Icons.download),
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
                              icon: const Icon(Icons.upload),
                            ),
                          ],
                        ),
                      ],
                      state.feeds.isEmpty
                          ? Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: pu6,
                                children: [
                                  const Icon(Icons.sentiment_neutral_outlined, size: 50),
                                  Text(locals.noFeeds, style: textTheme.bodyLarge),
                                ],
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: state.categories
                                    .where((c) =>
                                        !gReaderActive ||
                                        c.id != null ||
                                        state.feeds.any((f) => f.category == null))
                                    .length,
                                itemBuilder: (context, index) {
                                  final visibleCategories = state.categories
                                      .where((c) =>
                                          !gReaderActive ||
                                          c.id != null ||
                                          state.feeds.any((f) => f.category == null))
                                      .toList();
                                  final c = visibleCategories[index];
                                  return FeedCategoryView(
                                    category: c,
                                    feeds: state.feeds.where((f) => f.category?.id == c.id).toList(),
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
