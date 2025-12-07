import 'package:app/identity/states/identity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/router.dart';
import 'package:app/user/states/login.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class LoginFormScreen extends StatelessWidget {
  const LoginFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final locals = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => LoginCubit(LoginState(), serverUrl: serverUrl!),
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();
          final config = context.read<IdentityCubit>().state.config;
          return ErrorHandler<LoginCubit, LoginState>(
            child: Padding(
              padding: .only(right: 24),
              child: Column(
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                children: [
                  Align(alignment: .centerLeft, child: Text(locals.username)),
                  TextField(onChanged: (value) => cubit.setUser(value), autofillHints: [AutofillHints.username], autocorrect: false),
                  Gap(16),
                  Align(alignment: .centerLeft, child: Text(locals.password)),
                  TextField(obscureText: true, onChanged: (value) => cubit.setPassword(value), autofillHints: [AutofillHints.password], autocorrect: false),
                  if (state.failedLogin) ...[Gap(16), Text(locals.invalidCredentials, style: textTheme.bodyMedium?.copyWith(color: colors.error)), Gap(16)],
                  Gap(16),
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      if ((config?.allowSignup ?? false) && !(config?.demoMode ?? false)) TextButton(onPressed: () => AutoRouter.of(context).replace(SignupFormRoute()), child: Text(locals.signUp)),
                      Spacer(),
                      FilledButton.tonalIcon(
                        onPressed: state.loading
                            ? null
                            : () async {
                                try {
                                  cubit.setLoading(true);
                                  var token = await cubit.login();
                                  if (context.mounted) {
                                    await context.read<IdentityCubit>().setToken(token);
                                    if (context.mounted) {
                                      AutoRouter.of(context).replaceAll([HomeRoute()]);
                                    }
                                  }
                                } finally {
                                  if (context.mounted) {
                                    cubit.setLoading(false);
                                  }
                                }
                              },
                        label: Text(locals.login),
                        icon: Icon(Icons.login),
                      ),
                    ],
                  ),
                  if (config?.oidcConfig != null) ...[
                    Text(locals.or),
                    Gap(8),
                    FilledButton.tonal(
                      onPressed: () async {
                        final token = await cubit.logInWithOidc();

                        if (context.mounted) {
                          await context.read<IdentityCubit>().setToken(token);
                          if (context.mounted) {
                            AutoRouter.of(context).replaceAll([HomeRoute()]);
                          }
                        }
                      },
                      child: Text(locals.loginWith(config?.oidcConfig?.name ?? '')),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
