import 'package:app/identity/states/identity.dart';
import 'package:app/router.dart';
import 'package:app/user/states/login.dart';
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
    return BlocProvider(
      create: (context) => LoginCubit(LoginState(), serverUrl: context.read<IdentityCubit>().state.serverUrl!),
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();
          return Padding(
            padding: .only(right: 24),
            child: Column(
              crossAxisAlignment: .center,
              mainAxisAlignment: .center,
              children: [
                Align(alignment: .centerLeft, child: Text('Username')),
                TextField(onChanged: (value) => cubit.setUser(value)),
                Gap(16),
                Align(alignment: .centerLeft, child: Text('Password')),
                TextField(obscureText: true, onChanged: (value) => cubit.setPassword(value)),
                Gap(16),
                Align(
                  alignment: .centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: () async {
                      var token = await cubit.login();
                      if (context.mounted) {
                        context.read<IdentityCubit>().setToken(token);
                        AutoRouter.of(context).replaceAll([HomeRoute()]);
                      }
                    },
                    label: Text('Login'),
                    icon: Icon(Icons.login),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
