import 'package:app/l10n/app_localizations.dart';
import 'package:app/reset-password/services/reset_password_service.dart';
import 'package:app/router.dart';
import 'package:app/utils/dialog.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locals = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Align(alignment: .centerLeft, child: Text(locals.email)),
        TextField(autocorrect: false, controller: controller),
        Gap(pu2),
        Align(
          alignment: .centerRight,
          child: FilledButton.tonal(
            onPressed: () async {
              await ResetPasswordService(serverUrl!).submitRequest(email: controller.value.text);
              if (context.mounted) {
                okCancelDialog(
                  context,
                  title: locals.submitted,
                  content: Text(locals.passwordResetRequestSubmitted),
                  showCancel: false,
                  onOk: () {
                    AutoRouter.of(context).replace(LoginFormRoute());
                  },
                );
              }
            },
            child: Text(locals.submit),
          ),
        ),
      ],
    );
  }
}
