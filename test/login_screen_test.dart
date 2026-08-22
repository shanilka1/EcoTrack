import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/core/widgets/eco_logo.dart';
import 'package:ecotrack/features/auth/screens/login_screen.dart';
import 'package:ecotrack/features/onboarding/screens/onboarding_screen.dart';

void main() {
  group('LoginScreen UI & Validation Tests', () {
    testWidgets('Renders all required Login UI components',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Verify Logo & Headers
      expect(find.byType(EcoLogo), findsOneWidget);
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(
        find.text('Sign in to continue your EcoTrack journey.'),
        findsOneWidget,
      );

      // Verify Inputs & Buttons
      expect(find.widgetWithText(TextFormField, ''), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('Validates empty email and password on submit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Tap Sign In without filling form
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Validates invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, '').first,
        'invalid-email',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '').last,
        'secure123',
      );

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsNothing);
    });

    testWidgets('Toggles password visibility on eye icon tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Find password field
      final passwordFieldFinder = find.byType(EditableText).last;
      EditableText passwordField = tester.widget<EditableText>(passwordFieldFinder);
      expect(passwordField.obscureText, isTrue);

      // Tap show password icon
      await tester.tap(find.byTooltip('Show password'));
      await tester.pumpAndSettle();

      passwordField = tester.widget<EditableText>(passwordFieldFinder);
      expect(passwordField.obscureText, isFalse);

      // Tap hide password icon
      await tester.tap(find.byTooltip('Hide password'));
      await tester.pumpAndSettle();

      passwordField = tester.widget<EditableText>(passwordFieldFinder);
      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('Triggers onLoginSubmitted when inputs are valid',
        (WidgetTester tester) async {
      String submittedEmail = '';
      String submittedPassword = '';

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onLoginSubmitted: (email, password) {
              submittedEmail = email;
              submittedPassword = password;
            },
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, '').first,
        'test@ecotrack.org',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '').last,
        'password123',
      );

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(submittedEmail, 'test@ecotrack.org');
      expect(submittedPassword, 'password123');
    });

    testWidgets('Triggers onNavigateToRegister when Sign Up is tapped',
        (WidgetTester tester) async {
      bool registerTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onNavigateToRegister: () {
              registerTapped = true;
            },
          ),
        ),
      );

      final signUpFinder = find.text('Sign Up');
      await tester.ensureVisible(signUpFinder);
      await tester.tap(signUpFinder);
      await tester.pump();

      expect(registerTapped, isTrue);
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
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(LoginScreen), findsOneWidget);
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
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Onboarding Get Started navigates to LoginScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => const OnboardingScreen(),
            '/login': (_) => const LoginScreen(),
          },
        ),
      );

      // Skip to Page 3 & tap Get Started
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Verify Login Screen is displayed
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back!'), findsOneWidget);
    });
  });
}
