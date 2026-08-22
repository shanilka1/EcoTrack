import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/app.dart';
import 'package:ecotrack/features/onboarding/screens/onboarding_screen.dart';
import 'package:ecotrack/features/onboarding/widgets/onboarding_page_indicator.dart';

void main() {
  group('Onboarding Flow Tests', () {
    testWidgets('Renders Page 1 with correct title, description and Next button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      // Verify Page 1 elements
      expect(find.text('Track Your Habits'), findsOneWidget);
      expect(
        find.text(
          'Build better environmental habits by tracking your everyday eco-friendly actions.',
        ),
        findsOneWidget,
      );
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.byType(OnboardingPageIndicator), findsOneWidget);
    });

    testWidgets('Tapping Next navigates across all 3 pages to Get Started',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      // 1. On Page 1 -> tap Next
      expect(find.text('Track Your Habits'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // 2. On Page 2 -> verify elements & tap Next
      expect(find.text('Earn Eco Points'), findsOneWidget);
      expect(
        find.text(
          'Complete eco-friendly activities and earn points as you build positive habits.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // 3. On Page 3 -> verify elements & Get Started button
      expect(find.text('Make an Impact'), findsOneWidget);
      expect(
        find.text(
          'Complete challenges, unlock achievements and see your environmental progress.',
        ),
        findsOneWidget,
      );
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('Skip button navigates directly to the last page (Get Started)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      // On Page 1 -> tap Skip
      expect(find.text('Track Your Habits'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Now on Page 3
      expect(find.text('Make an Impact'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Tapping Get Started calls onCompleted callback',
        (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onCompleted: () {
              completed = true;
            },
          ),
        ),
      );

      // Skip to Page 3
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pump();

      expect(completed, isTrue);
    });

    testWidgets('Swipe gesture advances pages horizontally',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      expect(find.text('Track Your Habits'), findsOneWidget);

      // Fling left to swipe to page 2
      await tester.fling(
        find.byType(PageView),
        const Offset(-500.0, 0.0),
        1000.0,
      );
      await tester.pumpAndSettle();

      expect(find.text('Earn Eco Points'), findsOneWidget);
    });

    testWidgets('Renders with 0 overflow on small mobile screen (320x568)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('Renders with 0 overflow on tablet screen (800x1280)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('Splash Screen transitions to Onboarding Screen via AppRoutes',
        (WidgetTester tester) async {
      await tester.pumpWidget(const EcoTrackApp());

      // Advance through splash duration
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verify Onboarding Screen is now shown
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Track Your Habits'), findsOneWidget);
    });
  });
}
