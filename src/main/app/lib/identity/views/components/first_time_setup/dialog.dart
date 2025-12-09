import 'dart:ui';

import 'package:app/identity/states/identity.dart';
import 'package:app/identity/views/components/first_time_setup/done.dart';
import 'package:app/identity/views/components/first_time_setup/welcome.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/settings/views/components/feeds.dart';
import 'package:app/settings/views/components/layout.dart';
import 'package:app/user/services/user_service.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/states/simple_cubit.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/simple_cubit_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motor/motor.dart';

class FirstTimeSetupDialog extends StatefulWidget {
  const FirstTimeSetupDialog({super.key});

  @override
  State<FirstTimeSetupDialog> createState() => _FirstTimeSetupDialogState();
}

class _FirstTimeSetupDialogState extends State<FirstTimeSetupDialog> {
  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;


    final maxPages = BreakPoint.get(context) == .mobile ? 3 : 4;

    return SimpleCubitView<int>(
      initialValue: 0,
      builder: (context, page) => Center(
        child: Dialog(
          child: Column(
            mainAxisSize: .min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
                child: Align(
                  alignment: .centerLeft,
                  child: Text(switch (page) {
                    1 => locals.feeds,
                    2 => locals.layout,
                    _ => '',
                  }, style: textTheme.titleLarge),
                ),
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: BreakPoint.tablet.maxWidth),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedSwitcher(duration: Duration(milliseconds: 250), child: [Welcome(), FeedsSettingsTab(), LayoutSettingsTab(fadeColor: colors.surfaceContainerHigh,), Done()][page]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
                child: Row(
                  children: [
                    TextButton(onPressed: page == 0 ? null : () => context.read<SimpleCubit<int>>().setValue(page - 1), child: Text(locals.back)),
                    Expanded(
                      child: _Pager(page: page, maxPages: maxPages),
                    ),
                    if (page < maxPages - 1)
                      TextButton(onPressed: () => context.read<SimpleCubit<int>>().setValue(page + 1), child: Text(locals.next))
                    else
                      TextButton(
                        onPressed: () {
                          final user = context.read<IdentityCubit>().state.currentUser;
                          if(user != null) {
                            UserService(serverUrl!).updateUser(user.copyWith(firstTimeSetupDone: true));
                          }
                          Navigator.of(context).pop();
                          // save the user
                        },
                        child: Text(locals.done),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  final int page;
  final int maxPages;

  const _Pager({super.key, required this.page, required this.maxPages});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    List<Widget> widgets = [];

    for (int i = 0; i < maxPages; i++) {
      widgets.add(
        SingleMotionBuilder(
          value: i == page ? 1 : 0,
          from: 0,
          motion: MaterialSpringMotion.expressiveSpatialDefault(),
          builder: (context, value, child) {
            return Transform.scale(
              scale: lerpDouble(1, 2, value),
              child: Container(
                key: ValueKey(i),
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(colors.primary.withValues(alpha: 0), colors.secondary, value.clamp(0, 1)),
                  border: Border.all(color: colors.primary, width: 2),
                ),
              ),
            );
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(mainAxisAlignment: .center, spacing: 24, children: widgets),
    );
  }
}
