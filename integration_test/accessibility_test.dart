import 'package:browserstack_dart_sdk/browserstack_dart_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_browserstack/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BrowserStack.init();

  testWidgets('reads the accessibility results of this test', (tester) async {
    await tester.pumpWidget(const SampleApp());
    await tester.tap(find.byKey(const Key('increment')));
    await tester.pumpAndSettle();

    final Map<String, Object?> summary = await BrowserStack.accessibility.getResultsSummary();
    debugPrint('Accessibility summary: $summary');

    final List<Map<String, Object?>> issues = await BrowserStack.accessibility.getResults();
    debugPrint('Accessibility issues: ${issues.map((issue) => issue['issueName']).toList()}');
  });

  testWidgets('scans the screen on demand', (tester) async {
    await tester.pumpWidget(const SampleApp());
    await tester.pumpAndSettle();
    await BrowserStack.accessibility.performScan('home screen');
  });

  testWidgets('is left out of accessibility scans by its tag', (tester) async {
    await tester.pumpWidget(const SampleApp());
    await tester.tap(find.byKey(const Key('details')));
    await tester.pumpAndSettle();
    expect(find.text('Details page body'), findsOneWidget);
  }, tags: <String>['skipA11y']);
}
