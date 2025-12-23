import 'package:app/l10n/app_localizations.dart';
import 'package:app/reset-password/states/reset_password.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class ResetPasswordScreen extends StatelessWidget {
  final String? token;

  const ResetPasswordScreen({super.key, @queryParam this.token});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => ResetPasswordCubit(ResetPasswordState()),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: BreakPoint.tablet.maxWidth),
              child: Column(
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                spacing: pu3,
                children: [
                  Text(locals.resetPassword, style: textTheme.titleLarge),
                  BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                    builder: (context, state) {
                      final cubit = context.read<ResetPasswordCubit>();
                      return Container(
                        decoration: BoxDecoration(color: colors.surfaceContainerHigh, borderRadius: .circular(10)),
                        padding: .all(pu5),
                        child: Column(
                          crossAxisAlignment: .stretch,
                          children: [
                            Text(locals.newPassword),
                            TextField(controller: cubit.password, obscureText: true),
                            Gap(pu4),
                            Text(locals.resetPassword),
                            TextField(
                              controller: cubit.repeatPassword,
                              obscureText: true,
                              decoration: InputDecoration(
                                error: (state.password != state.repeatPassword) ? Text(locals.passwordsNotMatch) : null,
                              ),
                            ),
                            Gap(pu4),
                            Align(
                              alignment: .centerRight,
                              child: FilledButton.tonalIcon(onPressed: () {}, label: Text(locals.save)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
