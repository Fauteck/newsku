import 'package:app/identity/states/identity.dart';
import 'package:app/router.dart';
import 'package:app/user/states/login.dart';
import 'package:app/utils/views/components/error_listener.dart';
import 'package:auto_route/annotations.dart';
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

    return BlocProvider(
      create: (context) => LoginCubit(LoginState(), serverUrl: context.read<IdentityCubit>().state.serverUrl!),
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
                  Align(alignment: .centerLeft, child: Text('Username')),
                  TextField(onChanged: (value) => cubit.setUser(value), autofillHints: [AutofillHints.username], autocorrect: false),
                  Gap(16),
                  Align(alignment: .centerLeft, child: Text('Password')),
                  TextField(obscureText: true, onChanged: (value) => cubit.setPassword(value), autofillHints: [AutofillHints.password], autocorrect: false),
                  if (state.failedLogin) ...[Gap(16), Text('Invalid username or password', style: textTheme.bodyMedium?.copyWith(color: colors.error)), Gap(16)],
                  Gap(16),
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      if (config?.allowSignup ?? false) TextButton(onPressed: () => AutoRouter.of(context).replace(SignupFormRoute()), child: Text('Sign up')),
                      Spacer(),
                      FilledButton.tonalIcon(
                        onPressed: state.loading
                            ? null
                            : () async {
                                var token = await cubit.login();
                                if (context.mounted) {
                                  context.read<IdentityCubit>().setToken(token);
                                  AutoRouter.of(context).replaceAll([HomeRoute()]);
                                }
                              },
                        label: Text('Login'),
                        icon: Icon(Icons.login),
                      ),
                    ],
                  ),
                  if (config?.oidcConfig != null) ...[
                    Text('or'),
                    FilledButton.tonal(
                      onPressed: () async {
                        final token = await cubit.logInWithOidc();

                        if (context.mounted) {
                          context.read<IdentityCubit>().setToken(token);
                          AutoRouter.of(context).replaceAll([HomeRoute()]);
                        }
                      },
                      child: Text('Log in with ${config?.oidcConfig?.name}'),
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
