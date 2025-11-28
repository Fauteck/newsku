import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Center(
            child: Padding(
              padding: .symmetric(horizontal: 36),
              child: Column(
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                children: [Center(child: AutoRouter(
                  clipBehavior: .none,

                ))],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
