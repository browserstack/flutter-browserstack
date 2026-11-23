import 'package:browserstack_dart_sdk/browserstack_dart_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_browserstack/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Must be the first line of main(): it sets up Test Reporting and App Accessibility.
  BrowserStack.init();

  group('counter', () {
    testWidgets('increments once', (tester) async {
      await tester.pumpWidget(const SampleApp());
      expect(find.text('Count: 0'), findsOneWidget);
      await tester.tap(find.byKey(const Key('increment')));
      await tester.pumpAndSettle();
      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('increments twice', (tester) async {
      await tester.pumpWidget(const SampleApp());
      await tester.tap(find.byKey(const Key('increment')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('increment')));
      await tester.pumpAndSettle();
      expect(find.text('Count: 2'), findsOneWidget);
    });
  });

  group('form', () {
    testWidgets('greets the user', (tester) async {
      // integration_test doesn't route enterText to the app in release builds, which iOS on
      // BrowserStack needs. Registering the test text input makes it work in every build mode.
      tester.testTextInput.register();
      await tester.pumpWidget(const SampleApp());
      await tester.enterText(find.byKey(const Key('name')), 'BrowserStack');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('greet')));
      await tester.pumpAndSettle();
      expect(find.text('Hello, BrowserStack'), findsOneWidget);
    });
  });

  testWidgets('opens the details page', (tester) async {
    await tester.pumpWidget(const SampleApp());
    await tester.tap(find.byKey(const Key('details')));
    await tester.pumpAndSettle();
    expect(find.text('Details page body'), findsOneWidget);
  });
}
