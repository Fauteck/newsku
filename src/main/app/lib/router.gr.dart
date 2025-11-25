// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [FeedScreen]
class FeedRoute extends PageRouteInfo<void> {
  const FeedRoute({List<PageRouteInfo>? children})
    : super(FeedRoute.name, initialChildren: children, argsEquality: false);

  static const String name = 'FeedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FeedScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children, argsEquality: false);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [LandingScreen]
class LandingRoute extends PageRouteInfo<void> {
  const LandingRoute({List<PageRouteInfo>? children})
    : super(LandingRoute.name, initialChildren: children, argsEquality: false);

  static const String name = 'LandingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LandingScreen();
    },
  );
}

/// generated route for
/// [LoginFormScreen]
class LoginFormRoute extends PageRouteInfo<void> {
  const LoginFormRoute({List<PageRouteInfo>? children})
    : super(
        LoginFormRoute.name,
        initialChildren: children,
        argsEquality: false,
      );

  static const String name = 'LoginFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginFormScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    Key? key,
    String? url,
    Config? config,
    List<PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, url: url, config: config),
         initialChildren: children,
         argsEquality: false,
       );

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return LoginScreen(key: args.key, url: args.url, config: args.config);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.url, this.config});

  final Key? key;

  final String? url;

  final Config? config;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, url: $url, config: $config}';
  }
}

/// generated route for
/// [ServerUrlScreen]
class ServerUrlRoute extends PageRouteInfo<void> {
  const ServerUrlRoute({List<PageRouteInfo>? children})
    : super(
        ServerUrlRoute.name,
        initialChildren: children,
        argsEquality: false,
      );

  static const String name = 'ServerUrlRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ServerUrlScreen();
    },
  );
}
