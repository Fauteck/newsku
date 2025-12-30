import 'package:app/user/views/components/login_form.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';

import 'helper_widget/test_app_setup_widget.dart';
import 'test_utils.dart';

void main() {
  setUpAll(() {
    nock.init();
  });

  setUp(() async {
    await setupTests();
    nock.cleanAll();
  });

  testWidgets('Test full config login form all buttons available', (WidgetTester tester) async {
    // this will just test the whether all buttons are displayed properly, as our test config is "full"
    // this should show a signup,  login with OIDC, and forgot password buttons

    await tester.pumpWidget(TestSetup(child: LoginFormScreen()));

    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Log in with Test OIDC'), findsOneWidget);
    expect(find.text('Forgot password ?'), findsOneWidget);

    // now we set a different config where we all the buttons except login should be missing
    identityCubit.setUrl(
      validServerUrl,
      config: identityCubit.state.config?.copyWith(oidcConfig: null, allowSignup: false, canResetPassword: false),
    );
    await tester.pumpWidget(TestSetup(child: LoginFormScreen()));

    expect(find.text('Sign up'), findsNothing);
    expect(find.text('Log in with Test OIDC'), findsNothing);
    expect(find.text('Forgot password ?'), findsNothing);
  });

  testWidgets('Test user log in flow', (WidgetTester tester) async {
    await tester.pumpWidget(TestSetup(child: LoginFormScreen()));

    // we define a wrong and a correct password setup
    final invalidCredentialsInterceptor = nock(
      validServerUrl,
    ).post('/login', {'username': 'test', 'password': 'wrong password'})..reply(401, '');

    final username = find.byKey(Key('username'));
    final password = find.byKey(Key('password'));
    final loginButton = find.byKey(Key('login-button'));
    await tester.enterText(username, 'test');
    await tester.enterText(password, 'wrong password');

    await tester.tap(loginButton);

    await tester.pumpAndSettle();

    var invalidCredentials = find.text('Invalid username or password');

    expect(invalidCredentials, findsOneWidget);
    expect(invalidCredentialsInterceptor.isDone, true);

    final token = generateTestUserToken();

    final validCredentialsInterceptor = nock(
      validServerUrl,
    ).post('/login', {'username': 'test', 'password': 'correct password'})..reply(200, token);

    final userInterceptor = nock(validServerUrl).get('/api/users')..reply(200, loadFixture('user.json'));

    await tester.enterText(password, 'correct password');
    await tester.tap(loginButton);
    // we wait for page change
    await tester.pump(Duration(seconds: 1));

    expect(validCredentialsInterceptor.isDone, true);
    expect(userInterceptor.isDone, true);

    expect(identityCubit.state.token, token);
  });
}
