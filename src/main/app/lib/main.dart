import 'package:app/identity/states/identity.dart';
import 'package:app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

late final _appRouter;

final getIt = GetIt.instance;
final Color seedColor = Colors.deepOrange;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var identityCubit = IdentityCubit(IdentityState());
  await identityCubit.init();
  getIt.registerSingleton<IdentityCubit>(identityCubit);

  _appRouter = AppRouter(loggedInOnStart: identityCubit.isLoggedIn);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final inputTheme = InputDecorationThemeData(border: OutlineInputBorder());

    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => getIt.get<IdentityCubit>())],
      child: MaterialApp.router(
        title: 'NewsKu',
        routerConfig: _appRouter.config(),
        darkTheme: ThemeData(
          colorScheme: .fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
            surface: Color.fromARGB(255, 17, 18, 20),
            surfaceContainerHigh: Color.fromARGB(255, 35, 36, 40),
            onSurface: Colors.white,
          ),
          inputDecorationTheme: inputTheme
        ),

        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          inputDecorationTheme: inputTheme,
          colorScheme: .fromSeed(seedColor: seedColor, surface: Colors.white, surfaceContainerHigh: Color.fromARGB(255, 233, 234, 237), onSurface: Colors.black),
        ),
      ),
    );
  }
}
