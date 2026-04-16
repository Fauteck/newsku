import 'package:app/identity/states/identity.dart';
import 'package:app/router.dart';
import 'package:app/user/services/user_service.dart';
import 'package:app/utils/states/simple_cubit.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/simple_cubit_view.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FirstTimeSetupTrigger extends StatelessWidget {
  final Widget child;

  const FirstTimeSetupTrigger({super.key, required this.child});

  Future<void> navigateToSettings(BuildContext context) async {
    final user = context.read<IdentityCubit>().state.currentUser;
    if (user != null && serverUrl != null) {
      UserService(serverUrl!).updateUser(user.copyWith(firstTimeSetupDone: true));
    }
    context.router.push(SettingsRoute());
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCubitView<bool>(
      builder: (context, redirected) {
        final firstTimeSetupDone = context.select(
          (IdentityCubit c) => c.state.currentUser?.firstTimeSetupDone ?? false,
        );

        if (!redirected && !firstTimeSetupDone) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            context.read<SimpleCubit<bool>>().setValue(true);
            navigateToSettings(context);
          });
        }

        return child;
      },
      initialValue: false,
    );
  }
}
