import 'dart:ui';

import 'package:app/feed/models/feed.dart';
import 'package:app/feed/views/screens/classic_feed_screen.dart';
import 'package:app/feed/views/screens/feed_screen.dart';
import 'package:app/home/views/screens/home.dart';
import 'package:app/magazine/views/screens/public_magazine_screen.dart';
import 'package:app/reset-password/views/screens/reset_password.dart';
import 'package:app/settings/views/screens/feed_errors.dart';
import 'package:app/settings/views/screens/settings.dart';
import 'package:app/settings/views/tabs/ai.dart';
import 'package:app/settings/views/tabs/ai_activity_log.dart';
import 'package:app/settings/views/tabs/feeds.dart';
import 'package:app/settings/views/tabs/general.dart';
import 'package:app/settings/views/tabs/info.dart';
import 'package:app/settings/views/tabs/layout.dart';
import 'package:app/settings/views/tabs/user.dart';
import 'package:app/stats/views/screens/stats_screen.dart';
import 'package:app/stats/views/tabs/ai_stats.dart';
import 'package:app/stats/views/tabs/feed_stats.dart';
import 'package:app/stats/views/tabs/tag_stats.dart';
import 'package:app/user/views/components/forgot_password.dart';
import 'package:app/user/views/components/login.dart';
import 'package:app/user/views/components/login_form.dart';
import 'package:app/user/views/components/server_url.dart';
import 'package:app/user/views/components/signup_form.dart';
import 'package:app/user/views/screen/landing.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Tab,Route', argsEquality: false)
class AppRouter extends RootStackRouter {
  final bool loggedInOnStart;

  AppRouter({required this.loggedInOnStart});

  void loginRequired(NavigationResolver resolver, StackRouter router) {
    if (identityCubit.isLoggedIn) {
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
        path: '/',
        initial: loggedInOnStart,
        children: [
          AutoRoute(page: FeedRoute.page, path: '', initial: true),
          AutoRoute(page: ClassicFeedRoute.page, path: 'feed'),
          AutoRoute(
            page: StatsRoute.page,
            path: 'stats',
            children: [
              AutoRoute(page: TagStatsRoute.page, path: '', initial: true),
              AutoRoute(page: FeedStatsRoute.page, path: 'feeds'),
              AutoRoute(page: AiStatsRoute.page, path: 'ai'),
            ],
          ),
        ],
        onNavigation: loginRequired,
      ),
      AutoRoute.guarded(page: FeedErrorsRoute.page, path: '/feed-errors', onNavigation: loginRequired),
      AutoRoute.guarded(
        page: SettingsRoute.page,
        path: '/settings',
        onNavigation: loginRequired,
        children: [
          AutoRoute(page: FeedsSettingsRoute.page, path: '', initial: true),
          AutoRoute(page: LayoutSettingsRoute.page, path: 'layout'),
          AutoRoute(page: GeneralSettingsRoute.page, path: 'general'),
          AutoRoute(page: UserSettingsRoute.page, path: 'user'),
          AutoRoute(page: InfoRoute.page, path: 'info'),
        ],
      ),
      AutoRoute(page: ResetPasswordRoute.page, path: "/reset-password"),
      AutoRoute(page: PublicMagazineRoute.page, path: "/public/magazine/:tabId"),
      AutoRoute(
        page: LandingRoute.page,
        initial: !loggedInOnStart,
        children: [
          if (hasServerUrlSetup) AutoRoute(page: ServerUrlRoute.page, initial: hasServerUrlSetup),
          AutoRoute.guarded(
            onNavigation: serverUrlRequired,
            page: LoginRoute.page,
            initial: !hasServerUrlSetup,
            children: [
              AutoRoute(page: LoginFormRoute.page, initial: true),
              AutoRoute(page: SignupFormRoute.page),
              AutoRoute(page: ForgotPasswordRoute.page),
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
