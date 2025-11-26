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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 150,
        leading: ClipPath(
          clipper: FancySide(),
          child: Container(
            decoration: BoxDecoration(color: colors.primaryContainer),
            child: Padding(
              padding: .only(left: 24),
              child: Align(alignment: .centerLeft, child: Icon(Icons.newspaper)),
            ),
          ),
        ),
      ),
      body: AutoRouter(),
    );
  }
}
