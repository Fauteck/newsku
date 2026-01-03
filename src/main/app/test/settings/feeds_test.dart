import 'package:app/settings/views/tabs/feeds.dart';
import 'package:app/utils/views/components/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:snaptest/snaptest.dart';

import '../helper_widget/test_app_setup_widget.dart';
import '../test_utils.dart';

void main() {
  setUpAll(() {
    nock.init();
  });

  setUp(() async {
    await setupTests(loggedIn: true);
    nock.cleanAll();

    nock(validServerUrl).get('/api/users')
      ..reply(200, loadFixture('user.json'))
      ..persist(true);
  });

  testWidgets('Test happy path', (WidgetTester tester) async {
    final interceptor = nock(validServerUrl).get('/api/feeds')..reply(200, loadFixture('feeds.json'));

    await tester.pumpWidget(TestSetup(child: FeedsSettingsTab()));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorDialog), findsNothing);
    expect(interceptor.isDone, true);

    await snap(name: 'feed_settings', matchToGolden: true);
    // one of the feeds has errors so we expect them to shop up
    expect(find.textContaining('1337'), findsOneWidget);

    // now we want to add a feed
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    final putFeed = nock(validServerUrl).put('/api/feeds', (body) => true)..reply(200, loadFixture('one_feed.json'));
    nock(validServerUrl).get('/api/feeds')
      ..reply(200, loadFixture('feeds.json'))
      ..persist(true);

    await tester.enterText(textField, "http://someurl.com");
    await tester.tap(find.text('Add feed'));
    await tester.pumpAndSettle();

    expect(putFeed.isDone, true);

    final deleteFeed = nock(validServerUrl).delete('/api/feeds/1')..reply(200, 'true');

    final deleteButton = find.byIcon(Icons.delete).first;
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    final okButton = find.text("Ok");
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(okButton, findsOneWidget);

    await tester.tap(okButton);
    await tester.pumpAndSettle();

    expect(deleteFeed.isDone, true);
  });

  testWidgets('Test URL validation', (WidgetTester tester) async {
    final interceptor = nock(validServerUrl).get('/api/feeds')..reply(200, loadFixture('feeds.json'));

    await tester.pumpWidget(TestSetup(child: FeedsSettingsTab()));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorDialog), findsNothing);
    expect(interceptor.isDone, true);

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, "aaaaaa");
    await tester.tap(find.text('Add feed'));
    await tester.pumpAndSettle();

    await snap();

    expect(find.text('Invalid URL'), findsOneWidget);
  });

  testWidgets('test error while loading feeds', (WidgetTester tester) async {
    final interceptor = nock(validServerUrl).get('/api/feeds')..reply(500, '');

    await tester.pumpWidget(TestSetup(child: FeedsSettingsTab()));
    await tester.pumpAndSettle();

    await snap();

    expect(find.byType(ErrorDialog), findsOneWidget);
    expect(interceptor.isDone, true);
  });
}
