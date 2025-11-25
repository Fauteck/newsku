import 'package:app/config/models/config.dart';
import 'package:app/user/views/components/fancy_side.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class LoginScreen extends StatelessWidget {
  final String? url;
  final Config? config;

  const LoginScreen({super.key, this.url, this.config});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: .circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          ClipPath(
            clipper: FancySide(),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.rectangle, color: colors.primaryContainer, borderRadius: .circular(30)),
              width: 250,
              height: 200,
              child: Padding(
                padding: .only(left: 48),
                child: Align(alignment: .centerLeft, child: Icon(Icons.newspaper, size: 70)),
              ),
            ),
          ),
          Expanded(child: AutoRouter()),
        ],
      ),
    );
  }
}
