import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/features/auth/models/user_model.dart';
import 'package:ecotrack/features/profile/screens/about_screen.dart';
import 'package:ecotrack/features/profile/screens/change_password_screen.dart';
import 'package:ecotrack/features/profile/screens/edit_profile_screen.dart';
import 'package:ecotrack/features/profile/screens/legal_info_screen.dart';
import 'package:ecotrack/features/profile/screens/profile_screen.dart';
import 'package:ecotrack/features/profile/screens/settings_screen.dart';
import 'package:ecotrack/features/progress/models/user_statistics_model.dart';

void main() {
  final testUser = UserModel(
    uid: 'user-123',
    fullName: 'Jane Doe',
    email: 'jane@example.com',
    ecoPoints: 420,
    level: 3,
    createdAt: DateTime(2026, 1, 1),
  );

  const testStats = UserStatisticsModel(
    totalEcoPoints: 420,
    level: 3,
    totalActivitiesCompleted: 14,
    completedChallengesCount: 2,
    unlockedAchievementsCount: 5,
    weeklyDailyCounts: {},
    weeklyDailyPoints: {},
    categoryCounts: {},
    categoryPercentages: {},
    monthlyCounts: {},
  );

  group('ProfileScreen Widget Tests', () {
    testWidgets('Renders real user information and metrics correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            initialUser: testUser,
            initialStats: testStats,
          ),
        ),
      );

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('jane@example.com'), findsOneWidget);
      expect(find.text('Level 3 • Eco Enthusiast'), findsOneWidget);

      // Metrics
      expect(find.text('420'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      // Action items
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('My Progress & Stats'), findsOneWidget);
      expect(find.text('Badges & Achievements'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('Renders with 0 overflow on small mobile (320x568)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            initialUser: testUser,
            initialStats: testStats,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('EditProfileScreen Widget Tests', () {
    testWidgets('Populates initial user name and validates empty submit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditProfileScreen(initialUser: testUser),
        ),
      );

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('jane@example.com'), findsOneWidget);

      // Clear name and submit
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Full name cannot be empty.'), findsOneWidget);
    });
  });

  group('ChangePasswordScreen Widget Tests', () {
    testWidgets('Validates input fields and password match',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );

      expect(find.text('Change Password'), findsOneWidget);

      // Tap submit with empty fields
      await tester.tap(find.text('Update Password'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter your current password.'),
        findsOneWidget,
      );

      // Fill current and non-matching passwords
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'current123');
      await tester.enterText(fields.at(1), 'newpass123');
      await tester.enterText(fields.at(2), 'mismatch123');
      await tester.tap(find.text('Update Password'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });
  });

  group('SettingsScreen Widget Tests', () {
    testWidgets('Renders all setting sections and options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('About EcoTrack'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);

      // Tap Language option
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      expect(find.text('Select Language'), findsOneWidget);
      expect(find.text('Sinhala (සිංහල)'), findsOneWidget);
    });
  });

  group('About & Legal Screens Widget Tests', () {
    testWidgets('AboutScreen renders app version and mission',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      expect(find.text('About EcoTrack'), findsOneWidget);
      expect(find.text('Version 1.0.0 (Build 100)'), findsOneWidget);
      expect(find.text('Our Mission'), findsOneWidget);
    });

    testWidgets('LegalInfoScreen renders privacy policy and terms',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LegalInfoScreen.privacyPolicy(),
        ),
      );

      expect(find.text('Privacy Policy'), findsWidgets);
    });
  });
}
