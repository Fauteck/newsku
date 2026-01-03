import 'dart:ui';

import 'package:app/router.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';

import '../helper_widget/test_app_setup_widget.dart';
import '../test_utils.dart';

void main() {
  setUpAll(() {
    nock.init();
  });

  setUp(() async {
    await setupTests();
    nock.cleanAll();
  });

  testWidgets('Test whether the announcement text is displaying when it should', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(Size(800, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // we remove the announcement
    identityCubit.setUrl(validServerUrl, config: identityCubit.state.config?.copyWith(announcement: ''));

    await tester.pumpWidget(DeepLinkTestSetup(route: LoginRoute()));
    await tester.pumpAndSettle();

    final announcementPanel = find.byKey(Key('announcement'));

    expect(announcementPanel, findsNothing);

    // await snap(name:'login-with-announcement',matchToGolden: true);
    identityCubit.setUrl(
      validServerUrl,
      config: identityCubit.state.config?.copyWith(announcement: 'newsku announcement'),
    );

    // our default config has an announcement, so we just load the proper widget.
    await tester.pumpWidget(DeepLinkTestSetup(route: LoginRoute()));
    await tester.pumpAndSettle();

    expect(find.text(identityCubit.state.config!.announcement), findsOneWidget);
    expect(announcementPanel, findsOneWidget);
  });
}
