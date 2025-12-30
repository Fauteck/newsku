import 'dart:convert';
import 'dart:io';

import 'package:app/home/state/local_preferences.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setupTests() async {
  SharedPreferences.setMockInitialValues({});
  TestWidgetsFlutterBinding.ensureInitialized();
  var identityCubit = IdentityCubit(IdentityState());
  await identityCubit.init();
  getIt.registerSingleton<IdentityCubit>(identityCubit);

  getIt.registerSingleton<LocalPreferencesCubit>(LocalPreferencesCubit(LocalPreferencesState()));

  appRouter = AppRouter(loggedInOnStart: identityCubit.isLoggedIn);


}

String loadFixture(String name) {
  final file = File('test/fixtures/$name');
  return file.readAsStringSync();
}
