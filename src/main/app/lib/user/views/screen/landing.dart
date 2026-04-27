import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/app_name.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Center(
              child: Padding(
                padding: .symmetric(horizontal: pu9),
                child: Column(
                  crossAxisAlignment: .center,
                  mainAxisAlignment: .center,
                  children: [
                    AppName(style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: pu8),
                    Center(child: AutoRouter(clipBehavior: .none)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
