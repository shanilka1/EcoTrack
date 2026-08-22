import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/features/activities/models/eco_activity_model.dart';
import 'package:ecotrack/features/admin/models/admin_dashboard_stats_model.dart';
import 'package:ecotrack/features/admin/models/announcement_model.dart';
import 'package:ecotrack/features/admin/screens/admin_dashboard_screen.dart';
import 'package:ecotrack/features/admin/screens/manage_achievements_screen.dart';
import 'package:ecotrack/features/admin/screens/manage_activities_screen.dart';
import 'package:ecotrack/features/admin/screens/manage_announcements_screen.dart';
import 'package:ecotrack/features/admin/screens/manage_challenges_screen.dart';
import 'package:ecotrack/features/admin/screens/manage_users_screen.dart';
import 'package:ecotrack/features/auth/models/user_model.dart';
import 'package:ecotrack/features/challenges/models/challenge_model.dart';
import 'package:ecotrack/features/rewards/models/achievement_model.dart';

void main() {
  final sampleStats = const AdminDashboardStatsModel(
    totalUsers: 142,
    totalActivities: 18,
    activeChallenges: 4,
    totalAchievements: 12,
    totalAnnouncements: 3,
  );

  final sampleActivities = [
    EcoActivityModel(
      id: 'act-1',
      title: 'Plant a Tree',
      description: 'Plant a native tree sapling.',
      category: 'Nature',
      points: 50,
      environmentalBenefit: 'Absorbs CO2',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    EcoActivityModel(
      id: 'act-2',
      title: 'Compost Food Scraps',
      description: 'Compost organic waste.',
      category: 'Waste',
      points: 20,
      environmentalBenefit: 'Reduces landfill methane',
      isActive: false,
      createdAt: DateTime(2026, 1, 2),
      updatedAt: DateTime(2026, 1, 2),
    ),
  ];

  final sampleChallenges = [
    ChallengeModel(
      id: 'chal-1',
      title: 'Zero Waste Week',
      description: 'Complete 5 waste activities.',
      type: 'activity_count',
      target: 5,
      rewardPoints: 100,
      startDate: DateTime(2026, 8, 1),
      endDate: DateTime(2026, 8, 31),
      isActive: true,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    ),
  ];

  final sampleAchievements = [
    AchievementModel(
      id: 'ach-1',
      title: 'Green Pioneer',
      description: 'Log your first eco activity.',
      requirementType: 'first_activity',
      requirementValue: 1,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  final sampleUsers = [
    UserModel(
      uid: 'user-admin',
      fullName: 'Super Admin',
      email: 'admin@ecotrack.org',
      ecoPoints: 5200,
      level: 10,
      role: 'admin',
      createdAt: DateTime(2026, 1, 1),
    ),
    UserModel(
      uid: 'user-norm',
      fullName: 'Jane Green',
      email: 'jane@example.com',
      ecoPoints: 140,
      level: 2,
      role: 'user',
      createdAt: DateTime(2026, 2, 1),
    ),
  ];

  final sampleAnnouncements = [
    AnnouncementModel(
      id: 'ann-1',
      title: 'Global Earth Month Challenge',
      message: 'Join thousands of eco champions this month!',
      targetAudience: 'all',
      isActive: true,
      createdAt: DateTime(2026, 8, 20),
      createdBy: 'user-admin',
    ),
  ];

  group('AnnouncementModel Serialization Tests', () {
    test('Serializes and deserializes accurately', () {
      final ann = AnnouncementModel(
        id: 'ann-99',
        title: 'Platform Maintenance',
        message: 'Server upgrade at midnight.',
        targetAudience: 'all',
        isActive: true,
        createdAt: DateTime(2026, 8, 22, 12, 0),
        createdBy: 'admin-1',
      );

      final map = ann.toMap();
      final restored =
          AnnouncementModel.fromMap(map, documentId: 'ann-99');

      expect(restored.id, 'ann-99');
      expect(restored.title, 'Platform Maintenance');
      expect(restored.message, 'Server upgrade at midnight.');
      expect(restored.targetAudience, 'all');
      expect(restored.isActive, isTrue);
      expect(restored.createdBy, 'admin-1');
    });
  });

  group('Admin Dashboard Authorization & UI Tests', () {
    testWidgets('Non-admin user encounters Access Denied screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDashboardScreen(
            isVerifiedAdmin: false,
            initialStats: null,
          ),
        ),
      );

      expect(find.text('Access Denied'), findsOneWidget);
      expect(
        find.text(
          'You do not have administrative privileges to view or manage this console.',
        ),
        findsOneWidget,
      );
      expect(find.text('Return to App'), findsOneWidget);
    });

    testWidgets('Verified Admin sees live system metrics and management hubs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardScreen(
            isVerifiedAdmin: true,
            initialStats: sampleStats,
          ),
        ),
      );

      expect(find.text('Admin Console'), findsOneWidget);
      expect(find.text('Authorized Administrator'), findsOneWidget);
      expect(find.text('142'), findsOneWidget); // Total users
      expect(find.text('18'), findsOneWidget); // Total activities
      expect(find.text('4'), findsOneWidget); // Active challenges
      expect(find.text('12'), findsOneWidget); // Achievements

      expect(find.text('Manage Eco Activities'), findsOneWidget);
      expect(find.text('Manage Challenges'), findsOneWidget);
      expect(find.text('Manage Achievements'), findsOneWidget);
      expect(find.text('User Directory'), findsOneWidget);
      expect(find.text('System Announcements'), findsOneWidget);
    });
  });

  group('Manage Activities UI Tests', () {
    testWidgets('Renders activities with Active/Inactive badges',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ManageActivitiesScreen(
            initialActivities: sampleActivities,
          ),
        ),
      );

      expect(find.text('Manage Activities'), findsOneWidget);
      expect(find.text('Plant a Tree'), findsOneWidget);
      expect(find.text('Compost Food Scraps'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Inactive'), findsOneWidget);
      expect(find.text('New Activity'), findsOneWidget);
    });
  });

  group('Manage Challenges UI Tests', () {
    testWidgets('Renders challenges list with target and reward points',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ManageChallengesScreen(
            initialChallenges: sampleChallenges,
          ),
        ),
      );

      expect(find.text('Manage Challenges'), findsOneWidget);
      expect(find.text('Zero Waste Week'), findsOneWidget);
      expect(find.text('Target: 5 • Reward: +100 pts'), findsOneWidget);
      expect(find.text('New Challenge'), findsOneWidget);
    });
  });

  group('Manage Achievements UI Tests', () {
    testWidgets('Renders achievements list with requirement details',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ManageAchievementsScreen(
            initialAchievements: sampleAchievements,
          ),
        ),
      );

      expect(find.text('Manage Badges'), findsOneWidget);
      expect(find.text('Green Pioneer'), findsOneWidget);
      expect(find.text('Req: first_activity (1)'), findsOneWidget);
      expect(find.text('New Badge'), findsOneWidget);
    });
  });

  group('Manage Users UI Tests', () {
    testWidgets('Renders privacy-safe user list with ADMIN and USER badges',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ManageUsersScreen(
            initialUsers: sampleUsers,
          ),
        ),
      );

      expect(find.text('User Directory'), findsOneWidget);
      expect(find.text('Super Admin'), findsOneWidget);
      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.text('Jane Green'), findsOneWidget);
      expect(find.text('USER'), findsOneWidget);
    });

    testWidgets('Search input filters user list accurately',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ManageUsersScreen(
            initialUsers: sampleUsers,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Jane');
      await tester.pumpAndSettle();

      expect(find.text('Jane Green'), findsOneWidget);
      expect(find.text('Super Admin'), findsNothing);
    });
  });

  group('Manage Announcements UI Tests', () {
    testWidgets('Renders announcements list with active status and publish FAB',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ManageAnnouncementsScreen(
            initialAnnouncements: sampleAnnouncements,
          ),
        ),
      );

      expect(find.text('System Announcements'), findsOneWidget);
      expect(find.text('Global Earth Month Challenge'), findsOneWidget);
      expect(
        find.text('Join thousands of eco champions this month!'),
        findsOneWidget,
      );
      expect(find.text('New Announcement'), findsOneWidget);
    });
  });

  group('Responsive Layout Tests for Admin Consoles', () {
    testWidgets('Renders on small mobile (320x568) with 0 overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardScreen(
            isVerifiedAdmin: true,
            initialStats: sampleStats,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders on tablet (800x1280) with 0 overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardScreen(
            isVerifiedAdmin: true,
            initialStats: sampleStats,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
