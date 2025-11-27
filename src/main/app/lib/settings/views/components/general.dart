import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class GeneralSettingsTab extends StatelessWidget {
  const GeneralSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('general');
  }
}
