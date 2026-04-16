import 'package:app/identity/states/identity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/router.dart';
import 'package:app/user/states/server_url.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class ServerUrlScreen extends StatelessWidget {
  const ServerUrlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => ServerUrlCubit(ServerUrlState()),
      child: BlocBuilder<ServerUrlCubit, ServerUrlState>(
        builder: (context, state) {
          final cubit = context.read<ServerUrlCubit>();
          return Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            children: [
              Align(alignment: .centerLeft, child: Text(locals.server)),
              TextField(
                onChanged: (value) => cubit.setUrl(value),
                decoration: InputDecoration(error: state.error ? Text(locals.serverUrlUnreachable) : null),
              ),
              Gap(pu2),
              Align(
                alignment: .centerRight,
                child: FilledButton.tonalIcon(
                  key: Key('continue-button'),
                  onPressed: state.loading || state.config == null || state.error
                      ? null
                      : () {
                          context.read<IdentityCubit>().setUrl(state.serverUrl, config: state.config);
                          AutoRouter.of(context).push(LoginRoute());
                        },
                  label: Text(locals.continueToLogin),
                  icon: Icon(Icons.navigate_next),
                  iconAlignment: .end,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
