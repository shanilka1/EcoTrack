import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/features/auth/models/user_model.dart';
import 'package:ecotrack/features/home/screens/home_screen.dart';
import 'package:ecotrack/features/home/widgets/dashboard_header.dart';
import 'package:ecotrack/features/home/widgets/eco_points_card.dart';
import 'package:ecotrack/features/home/widgets/empty_state_card.dart';
import 'package:ecotrack/features/home/widgets/level_card.dart';
import 'package:ecotrack/features/home/widgets/quick_action_item.dart';

void main() {
  group('Home Dashboard UI & Real Data Tests', () {
    final testUser = UserModel(
      uid: 'user-xyz-12345',
      fullName: 'Chamari Atapattu',
      email: 'chamari@ecotrack.org',
      role: 'user',
      ecoPoints: 480,
      level: 4,
      createdAt: DateTime(2026, 8, 22),
    );

    testWidgets('Renders all actual Firestore user profile elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(initialUser: testUser),
        ),
      );

      // Verify User's Actual Name
      expect(find.text('Chamari Atapattu'), findsOneWidget);
      expect(find.byType(DashboardHeader), findsOneWidget);

      // Verify Actual Eco Points
      expect(find.text('480'), findsOneWidget);
      expect(find.text('Total Eco Points'), findsOneWidget);
      expect(find.byType(EcoPointsCard), findsOneWidget);

      // Verify Actual Level and Tier
      expect(find.text('Level 4'), findsWidgets);
      expect(find.text('Eco Enthusiast'), findsOneWidget);
      expect(find.byType(LevelCard), findsOneWidget);

      // Verify Quick Action Items
      expect(find.byType(QuickActionItem), findsNWidgets(4));
      expect(find.text('Activities'), findsOneWidget);
      expect(find.text('Challenges'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Badges'), findsOneWidget);

      // Verify Empty States for Activities and Challenges
      expect(find.byType(EmptyStateCard), findsNWidgets(2));
      expect(find.text('No activities completed today.'), findsOneWidget);
      expect(find.text('No active challenges.'), findsOneWidget);
    });

    testWidgets('Quick Actions render correctly on Home Screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(initialUser: testUser),
        ),
      );

      expect(find.text('Activities'), findsOneWidget);
      expect(find.text('Challenges'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Badges'), findsOneWidget);
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
        MaterialApp(
          home: HomeScreen(initialUser: testUser),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
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
        MaterialApp(
          home: HomeScreen(initialUser: testUser),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
