import 'dart:convert';
import 'dart:io';

import 'package:app/config/models/config.dart';
import 'package:app/home/state/local_preferences.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:nock/nock.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/path_provider.dart';

final String validServerUrl = 'http://localhost:123';

Future<void> setupTests({bool withConfig = true, bool loggedIn = false}) async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  await getIt.reset(dispose: true);

  SharedPreferences.setMockInitialValues({});
  TestWidgetsFlutterBinding.ensureInitialized();
  var identityCubit = IdentityCubit(IdentityState());
  await identityCubit.init();
  getIt.registerSingleton<IdentityCubit>(identityCubit);

  getIt.registerSingleton<LocalPreferencesCubit>(LocalPreferencesCubit(LocalPreferencesState()));

  if (withConfig) {
    final config = Config.fromJson(jsonDecode(loadFixture('valid_server_config.json')));
    identityCubit.setUrl(validServerUrl, config: config);
  }

  if (loggedIn) {
    nock(validServerUrl).get('/api/users').reply(200, loadFixture('user.json'));
    final token = generateTestUserToken();

    await identityCubit.setToken(token);

    nock.cleanAll();
  }

  PathProviderPlatform.instance = FakePathProviderPlatform();
}

String loadFixture(String name) {
  final file = File('test/fixtures/$name');
  return file.readAsStringSync();
}

String generateTestUserToken() {
  final jwt = JWT(
    // Payload
    {
      'user': {'id': 'cd2e4fe4-cd5f-476d-ac42-d031f6d813ea', 'email': 'test@test.com', 'username': 'test'},
    },
    subject: 'test',
    issuer: 'newsku',
  );

  // Sign it (default with HS256 algorithm)
  return jwt.sign(SecretKey('secret passphrase'), expiresIn: Duration(days: 1));
}
