import 'package:app/ai/models/openai_usage_log_entry.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/settings/states/ai_activity_log.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');
final _costFormat = NumberFormat('\$0.000000', 'en_US');

@RoutePage()
class AiActivityLogTab extends StatelessWidget {
  const AiActivityLogTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AiActivityLogCubit(),
      child: const _AiActivityLogView(),
    );
  }
}

class _AiActivityLogView extends StatelessWidget {
  const _AiActivityLogView();

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<AiActivityLogCubit, AiActivityLogState>(
      builder: (context, state) {
        final cubit = context.read<AiActivityLogCubit>();

        if (state.loading && state.entries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: colors.error, size: 48),
                Gap(pu2),
                Text(state.error.toString(), style: textTheme.bodySmall),
                Gap(pu2),
                FilledButton.tonalIcon(
                  onPressed: cubit.load,
                  icon: const Icon(Icons.refresh),
                  label: Text(locals.aiLogRetry),
                ),
              ],
            ),
          );
        }

        if (state.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 48, color: colors.onSurfaceVariant),
                Gap(pu2),
                Text(locals.aiLogEmpty, style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: cubit.load,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: pu2, vertical: pu4),
            itemCount: state.entries.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.entries.length) {
                return _LoadMoreButton(loading: state.loading, onPressed: cubit.loadMore);
              }
              return _LogEntryTile(entry: state.entries[index]);
            },
          ),
        );
      },
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  final OpenaiUsageLogEntry entry;

  const _LogEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;

    final isRelevance = entry.useCase == 'RELEVANCE';
    final icon = isRelevance ? Icons.auto_awesome : Icons.compress;
    final useCaseLabel = isRelevance ? locals.aiLogUseCaseRelevance : locals.aiLogUseCaseShortening;
    final iconColor = isRelevance ? colors.primary : colors.tertiary;

    return Card(
      margin: EdgeInsets.only(bottom: pu2),
      child: Padding(
        padding: EdgeInsets.all(pu3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            Gap(pu2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(useCaseLabel, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(
                        _dateFormat.format(entry.createdAt.toLocal()),
                        style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Gap(pu1),
                  Wrap(
                    spacing: pu2,
                    runSpacing: 4,
                    children: [
                      if (entry.model.isNotEmpty)
                        _Chip(label: entry.model, icon: Icons.smart_toy_outlined),
                      _Chip(
                        label: locals.aiLogTokenCount(entry.totalTokens),
                        icon: Icons.token_outlined,
                      ),
                      if (entry.estimatedCostUsd != null && entry.estimatedCostUsd! > 0)
                        _Chip(
                          label: _costFormat.format(entry.estimatedCostUsd),
                          icon: Icons.attach_money,
                        ),
                    ],
                  ),
                  Gap(pu1),
                  Text(
                    locals.aiLogTokenBreakdown(entry.promptTokens, entry.completionTokens),
                    style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label, style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _LoadMoreButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: pu4),
      child: Center(
        child: loading
            ? const CircularProgressIndicator()
            : OutlinedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.expand_more),
                label: Text(locals.aiLogLoadMore),
              ),
      ),
    );
  }
}
