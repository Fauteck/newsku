import 'package:app/router.dart';
import 'package:app/user/states/signup.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SignupFormScreen extends StatelessWidget {
  const SignupFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (context) => SignupCubit(SignupState()),
      child: BlocBuilder<SignupCubit, SignupState>(
        builder: (context, state) {
          final cubit = context.read<SignupCubit>();
          return Padding(
            padding: .only(right: 24),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Align(alignment: .centerLeft, child: Text('Username')),
                TextField(onChanged: (value) => cubit.setUsername(value), autofillHints: [AutofillHints.newUsername], autocorrect: false),
                Gap(16),
                Align(alignment: .centerLeft, child: Text('email')),
                TextField(onChanged: (value) => cubit.setEmail(value), autofillHints: [AutofillHints.email], autocorrect: false),
                Gap(16),
                Align(alignment: .centerLeft, child: Text('Password')),
                TextField(obscureText: true, onChanged: (value) => cubit.setPassword(value), autofillHints: [AutofillHints.newPassword], autocorrect: false),
                Gap(16),
                Align(alignment: .centerLeft, child: Text('Repeat password')),
                TextField(obscureText: true, onChanged: (value) => cubit.setRepeatPassword(value), autocorrect: false),
                Gap(16),
                if (state.password != state.repeatPassword) ...[Gap(16), Text('Passwords do not match', style: textTheme.bodyMedium?.copyWith(color: colors.error)), Gap(16)],
                Row(
                  children: [
                    TextButton(onPressed: () => AutoRouter.of(context).replace(LoginFormRoute()), child: Text('Log in')),
                    Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: state.loading || state.invalidForm
                          ? null
                          : () async {
                              await cubit.signup();
                              if (context.mounted) {
                                AutoRouter.of(context).replace(LoginFormRoute());
                              }
                            },
                      label: Text('Sign up'),
                      icon: Icon(Icons.login),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
