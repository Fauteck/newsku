import 'package:app/identity/views/components/first_time_setup_trigger.dart';
import 'package:app/identity/views/components/logout_listener.dart';
import 'package:app/utils/models/breakpoints.dart';
import 'package:app/utils/views/components/mobile_bottom_nav.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = BreakPoint.get(context) == BreakPoint.mobile;
    return LogoutListener(
      child: Scaffold(
        body: SafeArea(bottom: false, child: FirstTimeSetupTrigger(child: AutoRouter())),
        bottomNavigationBar: isMobile ? const MobileBottomNav() : null,
      ),
    );
  }
}
