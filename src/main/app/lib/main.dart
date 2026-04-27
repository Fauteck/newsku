import 'package:app/home/state/local_preferences.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/router.dart';
import 'package:app/utils/utils.dart';
import 'package:app/utils/views/components/main_color_provider.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import 'package:app/l10n/app_localizations.dart';

late final appRouter;

final getIt = GetIt.instance;

Future<void> main() async {
  usePathUrlStrategy();
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  WidgetsFlutterBinding.ensureInitialized();
  addAppLicense();
  var identityCubit = IdentityCubit(IdentityState());
  await identityCubit.init();
  getIt.registerSingleton<IdentityCubit>(identityCubit);

  getIt.registerSingleton<LocalPreferencesCubit>(LocalPreferencesCubit(LocalPreferencesState()));

  appRouter = AppRouter(loggedInOnStart: identityCubit.isLoggedIn);

  runApp(BetterFeedback(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildTheme(Color seed, Brightness brightness, Color surface, Color surfaceHigh, Color onSurface) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
        surface: surface,
        surfaceContainerHigh: surfaceHigh,
        onSurface: onSurface,
      ),
      inputDecorationTheme: InputDecorationThemeData(border: OutlineInputBorder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt.get<LocalPreferencesCubit>()),
        BlocProvider(create: (context) => getIt.get<IdentityCubit>()),
      ],
      child: BlocBuilder<LocalPreferencesCubit, LocalPreferencesState>(
        builder: (context, preferences) {
          return MainColorProvider(
            builder: (context, appColor) {
              return MaterialApp.router(
                onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: appRouter.config(),
                darkTheme: _buildTheme(
                  appColor, Brightness.dark,
                  preferences.blackBackground ? Colors.black : const Color(0xFF111214),
                  const Color(0xFF232428),
                  Colors.white,
                ),
                themeMode: preferences.theme,
                theme: _buildTheme(
                  appColor, Brightness.light,
                  Colors.white,
                  const Color(0xFFE9EAED),
                  Colors.black,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
