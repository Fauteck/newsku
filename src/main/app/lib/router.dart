import 'package:app/feed/views/screens/feed_screen.dart';
import 'package:app/home/views/screens/home.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:app/settings/views/components/feeds.dart';
import 'package:app/settings/views/components/layout.dart';
import 'package:app/settings/views/screens/settings.dart';
import 'package:app/user/views/components/login.dart';
import 'package:app/user/views/components/login_form.dart';
import 'package:app/user/views/components/server_url.dart';
import 'package:app/user/views/screen/landing.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

import 'settings/views/components/general.dart';
import 'user/views/components/signup_form.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Tab,Route', argsEquality: false)
class AppRouter extends RootStackRouter {
  final bool loggedInOnStart;

  AppRouter({required this.loggedInOnStart});

  void loginRequired(NavigationResolver resolver, StackRouter router) {
    if (getIt.get<IdentityCubit>().isLoggedIn) {
      resolver.next(true);
    } else {
      resolver.redirectUntil(!kIsWeb || kDebugMode ? ServerUrlRoute() : LoginFormRoute(), replace: true);
    }
  }

  void serverUrlRequired(NavigationResolver resolver, StackRouter router) {
    if (serverUrl != null) {
      resolver.next(true);
    } else {
      resolver.redirectUntil(ServerUrlRoute(), replace: true);
    }
  }

  @override
  List<AutoRoute> get routes {
    var hasServerUrlSetup = !kIsWeb || kDebugMode;
    return [
    AutoRoute.guarded(
      page: HomeRoute.page,
      initial: loggedInOnStart,
      children: [AutoRoute(page: FeedRoute.page, initial: true)],
      onNavigation: loginRequired,
    ),
    AutoRoute.guarded(
      page: SettingsRoute.page,
      onNavigation: loginRequired,
      children: [
        AutoRoute(page: FeedsSettingsRoute.page, initial: true),
        AutoRoute(page: LayoutSettingsRoute.page),
        AutoRoute(page: GeneralSettingsRoute.page),
      ],
    ),
    AutoRoute(
      page: LandingRoute.page,
      initial: !loggedInOnStart,
      children: [
        if(hasServerUrlSetup)AutoRoute(page: ServerUrlRoute.page, initial: hasServerUrlSetup),
        AutoRoute.guarded(
          onNavigation: serverUrlRequired,
          page: LoginRoute.page,
          initial: !hasServerUrlSetup,
          children: [
            AutoRoute(page: LoginFormRoute.page, initial: true),
            AutoRoute(page: SignupFormRoute.page),
          ],
        ),
      ],
    ),
  ];
  }

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
