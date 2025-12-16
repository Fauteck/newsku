import 'package:app/feed/models/feed_error.dart';
import 'package:app/feed/views/screens/feed_screen.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/utils/states/simple_cubit.dart';
import 'package:app/utils/views/components/simple_cubit_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

final _errorDateFormat = DateFormat.yMMMd().add_Hms();

class FeedErrorView extends StatelessWidget {
  final FeedError error;

  const FeedErrorView({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;

    var titlesTheme = textTheme.labelSmall?.copyWith(color: colors.tertiary);

    return SelectionArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SimpleCubitView<bool>(
          initialValue: false,
          builder: (context, expanded) {
            return Column(
              crossAxisAlignment: .stretch,
              children: [
                Text(
                  _errorDateFormat.format(DateTime.fromMillisecondsSinceEpoch(error.timeCreated)),
                  style: textTheme.labelMedium?.copyWith(color: colors.secondary),
                ),
                Gap(16),
                if (error.url == null)
                  Text(locals.feedRetrievalError)
                else ...[
                  Text(locals.articleUrl, style: titlesTheme),
                  Text(error.url ?? ''),
                ],
                Gap(16),
                Text(locals.error, style: titlesTheme),
                Text(error.message),

                Gap(16),
                Align(
                  alignment: .centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.read<SimpleCubit<bool>>().setValue(!expanded),
                    label: Text(locals.stackTrace),
                    icon: expanded ? Icon(Icons.expand_more) : Icon(Icons.expand_less),
                  ),
                ),
                if (expanded) Padding(padding: const EdgeInsets.all(8.0), child: Text(error.error ?? '')),
              ],
            );
          },
        ),
      ),
    );
  }
}
