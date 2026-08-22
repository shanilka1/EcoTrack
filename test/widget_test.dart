import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/app.dart';
import 'package:ecotrack/core/constants/app_strings.dart';

void main() {
  testWidgets('EcoTrackApp initial smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EcoTrackApp());

    // Verify that EcoTrack title is displayed on splash screen
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);
  });
}
