import 'package:app/identity/states/identity.dart';
import 'package:app/identity/views/components/logout_listener.dart';
import 'package:app/main.dart';
import 'package:app/user/views/components/fancy_side.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LogoutListener(
      child: Scaffold(body: SafeArea(bottom: false, child: AutoRouter())),
    );
  }
}
