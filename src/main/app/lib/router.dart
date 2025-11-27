import 'package:app/feed/views/screens/feed_screen.dart';
import 'package:app/home/views/screens/home.dart';
import 'package:app/settings/views/components/feeds.dart';
import 'package:app/settings/views/screens/settings.dart';
import 'package:app/user/views/components/login.dart';
import 'package:app/user/views/components/login_form.dart';
import 'package:app/user/views/components/server_url.dart';
import 'package:app/user/views/screen/landing.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

import 'config/models/config.dart';
import 'settings/views/components/general.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Tab,Route', argsEquality: false)
class AppRouter extends RootStackRouter {
  final bool loggedInOnStart;

  AppRouter({required this.loggedInOnStart});

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      initial: loggedInOnStart,
      children: [AutoRoute(page: FeedRoute.page, initial: true)],
    ),
    AutoRoute(page: SettingsRoute.page, children: [
      AutoRoute(page: FeedsSettingsRoute.page, initial: true),
      AutoRoute(page: GeneralSettingsRoute.page)
    ]),
    AutoRoute(
      page: LandingRoute.page,
      initial: !loggedInOnStart,
      children: [
        AutoRoute(page: ServerUrlRoute.page, initial: !kIsWeb || kDebugMode),
        AutoRoute(
          page: LoginRoute.page,
          initial: kIsWeb && !kDebugMode,
          children: [AutoRoute(page: LoginFormRoute.page, initial: true)],
        ),
      ],
    ),
  ];

  /*
  @override
  late final List<AutoRouteGuard> guards = [AutoRouteGuard.simple(onNavigation)];

  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    bool needLogin = false;
    try {
      final url = await service.getUrl();
      if (url.trim().isEmpty) {
        needLogin = true;
      } else {
        needLogin = await service.needLogin();
      }
    } catch (e) {
      needLogin = true;
    }
    if (!needLogin || resolver.route.name == LoginRoute.name) {
      // we continue navigation
      resolver.next();
    } else {
      // else we navigate to the Login page so we get authenticated

      // tip: use resolver.redirect to have the redirected route
      // automatically removed from the stack when the resolver is completed
      resolver.redirectUntil(const LoginRoute(), replace: true);
    }
  }
*/
}
