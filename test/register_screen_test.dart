import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/core/widgets/eco_logo.dart';
import 'package:ecotrack/features/auth/screens/login_screen.dart';
import 'package:ecotrack/features/auth/screens/register_screen.dart';

void main() {
  group('RegisterScreen UI & Validation Tests', () {
    testWidgets('Renders all required Register UI components',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      // Verify Headers & Branding
      expect(find.byType(EcoLogo), findsOneWidget);
      expect(find.text('Create Account'), findsWidgets);
      expect(
        find.text('Start your journey toward a greener lifestyle.'),
        findsOneWidget,
      );

      // Verify 4 Input Fields
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);

      // Verify Checkbox & Buttons
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('I agree to the '), findsOneWidget);
      expect(find.text('Terms and Conditions'), findsOneWidget);
      expect(find.text('Sign up with Google'), findsOneWidget);
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Validates empty inputs and unchecked terms on submit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      // Tap Create Account button
      final createAccountBtn = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.ensureVisible(createAccountBtn);
      await tester.tap(createAccountBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
      expect(
        find.text('You must accept the Terms and Conditions to continue'),
        findsOneWidget,
      );
    });

    testWidgets('Validates password mismatch', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      // Fill in name, email, password, but different confirm password
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Kasun Perera',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'kasun@ecotrack.org',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'password123',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'differentPassword',
      );

      // Check Terms checkbox
      final checkboxFinder = find.byType(Checkbox);
      await tester.ensureVisible(checkboxFinder);
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Tap Create Account
      final createAccountBtn = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.ensureVisible(createAccountBtn);
      await tester.tap(createAccountBtn);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Toggles password visibility for both password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      // Password field
      final passwordFieldFinder = find.byType(EditableText).at(2);
      expect(tester.widget<EditableText>(passwordFieldFinder).obscureText, isTrue);

      // Tap show password
      await tester.tap(find.byTooltip('Show password'));
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(passwordFieldFinder).obscureText, isFalse);

      // Confirm password field
      final confirmPasswordFieldFinder = find.byType(EditableText).at(3);
      expect(
        tester.widget<EditableText>(confirmPasswordFieldFinder).obscureText,
        isTrue,
      );

      // Tap show confirm password
      await tester.tap(find.byTooltip('Show confirm password'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(confirmPasswordFieldFinder).obscureText,
        isFalse,
      );
    });

    testWidgets('Triggers onRegisterSubmitted when all inputs are valid',
        (WidgetTester tester) async {
      String submittedName = '';
      String submittedEmail = '';
      String submittedPassword = '';

      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(
            onRegisterSubmitted: (name, email, password) {
              submittedName = name;
              submittedEmail = email;
              submittedPassword = password;
            },
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Nimal Silva',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'nimal@ecotrack.org',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'securePass123',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'securePass123',
      );

      // Check Terms
      final checkboxFinder = find.byType(Checkbox);
      await tester.ensureVisible(checkboxFinder);
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Submit
      final createAccountBtn = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.ensureVisible(createAccountBtn);
      await tester.tap(createAccountBtn);
      await tester.pumpAndSettle();

      expect(submittedName, 'Nimal Silva');
      expect(submittedEmail, 'nimal@ecotrack.org');
      expect(submittedPassword, 'securePass123');
    });

    testWidgets('Login Screen navigates to Register Screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
          },
        ),
      );

      final signUpFinder = find.text('Sign Up');
      await tester.ensureVisible(signUpFinder);
      await tester.tap(signUpFinder);
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('Register Screen navigates back to Login Screen on Sign In tap',
        (WidgetTester tester) async {
      bool loginTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(
            onNavigateToLogin: () {
              loginTapped = true;
            },
          ),
        ),
      );

      final signInFinder = find.text('Sign In');
      await tester.ensureVisible(signInFinder);
      await tester.tap(signInFinder);
      await tester.pump();

      expect(loginTapped, isTrue);
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
          home: RegisterScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(RegisterScreen), findsOneWidget);
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
          home: RegisterScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(RegisterScreen), findsOneWidget);
    });
  });
}
