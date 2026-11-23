# flutter-browserstack

A sample Flutter app with `integration_test` tests that run on real Android and iOS devices on [BrowserStack App Automate](https://www.browserstack.com/app-automate). The tests send their results to [Test Reporting & Analytics](https://www.browserstack.com/test-reporting-and-analytics) and the screens they open are checked for accessibility issues by [App Accessibility](https://www.browserstack.com/app-accessibility).

Both products come from the BrowserStack Dart package [`browserstack_dart_sdk`](https://pub.dev/packages/browserstack_dart_sdk). You add the package and one line to your tests, and turn each product on in the API call that starts the build.

## What's in this repo

| Path | What it is |
|---|---|
| `lib/main.dart` | The app: a counter, a form and a details page. It has two accessibility issues on purpose, so the App Accessibility report has something to show. |
| `integration_test/app_test.dart` | Tests for the app. |
| `integration_test/accessibility_test.dart` | Tests that read App Accessibility results from test code, scan on demand, and skip scans with a tag. |
| `android/app/src/androidTest/java/com/browserstack/flutter_browserstack/MainActivityTest.java` | Runs the Flutter tests through Android instrumentation. |
| `ios/RunnerTests/RunnerTests.m` | Runs the Flutter tests through XCTest. |

## Before you start

- A BrowserStack account with App Automate. Your username and access key are on your [account settings](https://www.browserstack.com/accounts/settings) page.
- Flutter. This sample was tested with Flutter 3.47.6; the package supports Flutter 3.13 and later.
- For iOS: a Mac with Xcode.
- App Accessibility runs on Android 11 and later, and iOS 14 and later.

Set your credentials in the terminal you'll use:

```sh
export BROWSERSTACK_USERNAME="YOUR_USERNAME"
export BROWSERSTACK_ACCESS_KEY="YOUR_ACCESS_KEY"
```

Then get the dependencies:

```sh
git clone https://github.com/browserstack/flutter-browserstack.git
cd flutter-browserstack
flutter pub get
```

## Run the tests on Android

**1. Build the app and the test APK.** The `-t` file decides which tests go into the app.

```sh
flutter build apk --debug -t integration_test/app_test.dart
cd android && ./gradlew app:assembleAndroidTest && cd ..
```

This gives you:
- the app: `build/app/outputs/apk/debug/app-debug.apk`
- the test suite: `build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk`

**2. Upload both.** Each call returns an id (`app_url`, `test_suite_url`) that starts with `bs://`.

```sh
curl -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/app" \
  -F "file=@build/app/outputs/apk/debug/app-debug.apk"

curl -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/test-suite" \
  -F "file=@build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"
```

**3. Start the build** with your two ids. `testObservability` turns on Test Reporting & Analytics, and `accessibility` turns on App Accessibility.

```sh
curl -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/build" \
  -H "Content-Type: application/json" \
  -d '{
    "app": "bs://YOUR_APP_ID",
    "testSuite": "bs://YOUR_TEST_SUITE_ID",
    "devices": ["Google Pixel 7-13.0"],
    "project": "flutter-browserstack-sample",
    "testObservability": true,
    "accessibility": true
  }'
```

## Run the tests on iOS

**1. Build the test package.** BrowserStack signs it for the device, so you don't need a signing identity.

```sh
flutter build ios --release --no-codesign -t integration_test/app_test.dart

cd ios
xcodebuild build-for-testing \
  -workspace Runner.xcworkspace -scheme Runner \
  -configuration Release -xcconfig Flutter/Release.xcconfig \
  -derivedDataPath ../build/ios_integration -sdk iphoneos \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
cd ..

cd build/ios_integration/Build/Products
zip -r ../../../ios_tests.zip Release-iphoneos ./*.xctestrun
cd ../../../..
```

This gives you `build/ios_tests.zip`.

**2. Upload it.** The call returns a `test_package_url` that starts with `bs://`.

```sh
curl -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/ios/test-package" \
  -F "file=@build/ios_tests.zip"
```

**3. Start the build.**

```sh
curl -u "$BROWSERSTACK_USERNAME:$BROWSERSTACK_ACCESS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/ios/build" \
  -H "Content-Type: application/json" \
  -d '{
    "testPackage": "bs://YOUR_TEST_PACKAGE_ID",
    "devices": ["iPhone 15-17"],
    "project": "flutter-browserstack-sample",
    "testObservability": true,
    "accessibility": true
  }'
```

## See the results

- **[App Automate](https://app-automate.browserstack.com/dashboard/v2):** the build, its sessions, video and device logs.
- **[Test Reporting & Analytics](https://automation.browserstack.com):** open the `flutter-browserstack-sample` project. Each test shows its status, duration, group and logs.
- **[App Accessibility](https://app-accessibility.browserstack.com/automated-tests):** open the same project. Each test shows the screens that were scanned and the issues found on them.

## Add BrowserStack to your own app

1. Add the package as a dev dependency:

   ```sh
   flutter pub add --dev browserstack_dart_sdk
   ```

2. Call `BrowserStack.init()` as the first line of `main()` in every integration test file:

   ```dart
   import 'package:browserstack_dart_sdk/browserstack_dart_sdk.dart';
   import 'package:flutter_test/flutter_test.dart';

   void main() {
     BrowserStack.init();

     testWidgets('my test', (tester) async {
       // ...
     });
   }
   ```

   `BrowserStack.init()` sets up the integration test binding, so call it before anything else in `main()`. If your tests call `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`, remove that line or move it after `BrowserStack.init()`. If the binding is created first, fewer actions get an accessibility scan.

3. Make sure your app has the native test runners that `integration_test` needs on BrowserStack, as in this repo:
   - Android: an instrumentation test like `MainActivityTest.java`, and `testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"` in `android/app/build.gradle.kts`.
   - iOS: a `RunnerTests` target with `RunnerTests.m`.

   See [Flutter's integration_test guide](https://docs.flutter.dev/testing/integration-tests) for how to add them.

4. Build, upload and start the build as shown above.

You don't need any other code. When the tests run anywhere other than BrowserStack, such as with `flutter test` on your machine, `BrowserStack.init()` only sets up the binding, so the same tests still run as before.

## App Accessibility in your tests

App Accessibility scans the screen before each action your test takes (a tap, a drag, entering text and so on) and once at the end of each test. It scans what's on the screen at that moment, so call `await tester.pumpAndSettle()` after each step to let the app finish drawing before the next action.

From test code you can also:
- get a summary of the issues found so far in the test: `await BrowserStack.accessibility.getResultsSummary()`
- get the list of those issues: `await BrowserStack.accessibility.getResults()`
- scan the screen at any point: `await BrowserStack.accessibility.performScan('name of the scan')`

`integration_test/accessibility_test.dart` shows all three. To run it, build with `-t integration_test/accessibility_test.dart` and add the `skipA11y` option below to the build request.

Options go in `accessibilityOptions` in the build request. For example, to skip scans in tests tagged `skipA11y`:

```json
"accessibility": true,
"accessibilityOptions": {
  "excludeTagsInTestingScope": ["skipA11y"]
}
```

Other options:

| Option | What it does |
|---|---|
| `includeTagsInTestingScope` | Scan only tests with one of these tags, for example `["a11y"]`. |
| `excludeTagsInTestingScope` | Don't scan tests with one of these tags. |
| `wcagVersion` | WCAG version to check against, for example `"wcag21aa"`. |
| `includeIssueType` | Turn off issue types, for example `{"bestPractice": false, "needsReview": false}`. |

Tags are the standard Dart test tags: `testWidgets('...', (tester) async { ... }, tags: ['a11y'])`.

## Good to know

- iOS builds for BrowserStack are release builds, and in release builds `integration_test` doesn't pass `enterText` to your app. Call `tester.testTextInput.register()` at the start of tests that type text, as `integration_test/app_test.dart` does.
- Requests your app makes with Dart's own `HttpClient` don't go through the device's proxy. They won't show in network logs, and they can't reach [BrowserStack Local](https://www.browserstack.com/docs/app-automate/flutter/get-started-with-local-testing) unless your app sets the proxy itself. This doesn't affect Test Reporting or App Accessibility.
- To see what the package does on the device, build with `--dart-define=BROWSERSTACK_SDK_DEBUG=true` and add `"deviceLogs": true` to the build request. The package's log lines then show in the device logs.

## Help

- [App Automate for Flutter docs](https://www.browserstack.com/docs/app-automate/flutter)
- [BrowserStack support](https://www.browserstack.com/support)
