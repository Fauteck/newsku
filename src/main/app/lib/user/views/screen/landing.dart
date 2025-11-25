import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

    },);
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 550,
          height: 300,
          child: AutoRouter(clipBehavior: Clip.none,),
        ),
      ),
    );
  }
}
