import 'package:app/l10n/app_localizations.dart';
import 'package:app/stats/states/stats_state.dart';
import 'package:app/stats/views/components/stat_bar.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class TagStatsTab extends StatelessWidget {
  const TagStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;
    final stats = context.read<StatsCubit>().state.stats.tagClicks;

    return Padding(
      padding: .only(top: pu4),
      child: Column(
        spacing: pu4,
        children: [
          Text(locals.tagStatsExplanation),
          Expanded(
            child: ListView.builder(
              itemCount: stats.length,
              itemBuilder: (context, index) {
                var s = stats[index];
                return StatBar(
                  heading: Row(
                    children: [
                      Expanded(child: Text(s.tag)),
                      Text(s.clicks.toString()),
                    ],
                  ),
                  value: s.clicks,
                  max: stats.first.clicks,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
