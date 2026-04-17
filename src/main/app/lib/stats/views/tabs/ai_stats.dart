import 'package:app/ai/models/openai_usage.dart';
import 'package:app/ai/states/openai_usage.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class AiStatsTab extends StatelessWidget {
  const AiStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OpenaiUsageCubit(const OpenaiUsageState()),
      child: ErrorHandler<OpenaiUsageCubit, OpenaiUsageState>(
        child: const _AiStatsBody(),
      ),
    );
  }
}

class _AiStatsBody extends StatelessWidget {
  const _AiStatsBody();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;
    final subTextTheme = textTheme.labelMedium?.copyWith(color: colors.secondary);

    return BlocBuilder<OpenaiUsageCubit, OpenaiUsageState>(
      builder: (context, state) {
        final cubit = context.read<OpenaiUsageCubit>();

        return RefreshIndicator(
          onRefresh: cubit.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: pu4, bottom: pu8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(locals.openAiUsageTitle, style: textTheme.titleMedium),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: state.loading ? null : cubit.refresh,
                    ),
                  ],
                ),
                Gap(pu1),
                Text(locals.openAiUsageExplanation, style: subTextTheme),
                Gap(pu3),
                _PeriodSelector(
                  period: state.period,
                  onChanged: (p) => cubit.setPeriod(p),
                ),
                Gap(pu4),
                if (state.loading && state.relevance == null && state.shortening == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _UsageCard(label: locals.openAiUseCaseRelevance, stats: state.relevance),
                  Gap(pu2),
                  _UsageCard(label: locals.openAiUseCaseShortening, stats: state.shortening),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final UsagePeriod period;
  final ValueChanged<UsagePeriod> onChanged;

  const _PeriodSelector({required this.period, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;
    return SegmentedButton<UsagePeriod>(
      segments: [
        ButtonSegment(value: UsagePeriod.day, label: Text(locals.aiUsagePeriodDay)),
        ButtonSegment(value: UsagePeriod.week, label: Text(locals.aiUsagePeriodWeek)),
        ButtonSegment(value: UsagePeriod.month, label: Text(locals.aiUsagePeriodMonth)),
      ],
      selected: {period},
      onSelectionChanged: (selected) => onChanged(selected.first),
      showSelectedIcon: false,
    );
  }
}

class _UsageCard extends StatelessWidget {
  final String label;
  final OpenAiUsageStats? stats;

  const _UsageCard({required this.label, required this.stats});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;

    final total = stats?.totalTokens ?? 0;
    final calls = stats?.callCount ?? 0;
    final limit = stats?.monthlyLimit;
    final remaining = (limit == null) ? null : (limit - total).clamp(0, limit);
    final limitReached = limit != null && total >= limit;
    final cost = stats?.estimatedCostUsd;
    final breakdown = stats?.modelBreakdown ?? const [];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(pu3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (limitReached)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      locals.openAiUsageLimitReached,
                      style: textTheme.labelSmall?.copyWith(color: colors.onErrorContainer),
                    ),
                  ),
              ],
            ),
            Gap(pu1),
            Text(locals.openAiUsageTokens(total), style: textTheme.bodyLarge),
            Text(
              locals.openAiUsageCalls(calls),
              style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            Gap(pu1),
            Text(
              locals.aiUsageCost(_formatCost(cost)),
              style: textTheme.bodyMedium?.copyWith(color: colors.primary),
            ),
            if (limit != null) ...[
              Gap(pu2),
              LinearProgressIndicator(
                value: (total / limit).clamp(0, 1).toDouble(),
                color: limitReached ? colors.error : colors.primary,
                backgroundColor: colors.surfaceContainerHighest,
              ),
              Gap(pu1),
              Text(
                '${locals.openAiUsageLimit}: $limit — ${locals.openAiUsageRemaining(remaining ?? 0)}',
                style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ] else ...[
              Gap(pu1),
              Text(
                locals.openAiUsageLimitUnset,
                style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
            if (breakdown.isNotEmpty) ...[
              Gap(pu3),
              Text(
                locals.aiUsageByModel,
                style: textTheme.labelMedium?.copyWith(color: colors.secondary),
              ),
              Gap(pu1),
              ...breakdown.map((m) => _ModelRow(model: m)),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatCost(double? cost) {
    if (cost == null) return '—';
    if (cost < 0.01) return '\$${cost.toStringAsFixed(4)}';
    return '\$${cost.toStringAsFixed(2)}';
  }
}

class _ModelRow extends StatelessWidget {
  final OpenAiModelUsage model;

  const _ModelRow({required this.model});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(model.model, style: textTheme.bodySmall)),
          Text(
            '${model.totalTokens}',
            style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          SizedBox(width: pu3),
          SizedBox(
            width: 70,
            child: Text(
              _formatCost(model.estimatedCostUsd),
              textAlign: TextAlign.right,
              style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCost(double? cost) {
    if (cost == null) return '—';
    if (cost < 0.01) return '\$${cost.toStringAsFixed(4)}';
    return '\$${cost.toStringAsFixed(2)}';
  }
}
