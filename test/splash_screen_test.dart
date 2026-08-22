import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/app.dart';
import 'package:ecotrack/core/constants/app_strings.dart';
import 'package:ecotrack/core/widgets/eco_logo.dart';
import 'package:ecotrack/features/splash/screens/splash_screen.dart';

void main() {
  group('SplashScreen UI & Responsiveness Tests', () {
    testWidgets('Renders all branding elements and logo',
        (WidgetTester tester) async {
      await tester.pumpWidget(const EcoTrackApp());

      // Advance animation partially
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(EcoLogo), findsOneWidget);
      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text(AppStrings.appTagline), findsOneWidget);
    });

    testWidgets('Triggers completion callback after duration',
        (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            splashDuration: const Duration(seconds: 2),
            onSplashComplete: () {
              completed = true;
            },
          ),
        ),
      );

      // Fast forward animation
      await tester.pump(const Duration(seconds: 1));
      expect(completed, isFalse);

      await tester.pump(const Duration(seconds: 1));
      expect(completed, isTrue);
    });

    testWidgets('Renders without overflow on small mobile screen (320x568)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const EcoTrackApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('Renders without overflow on tablet screen (800x1280)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const EcoTrackApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.byType(SplashScreen), findsOneWidget);
    });
  });
}
