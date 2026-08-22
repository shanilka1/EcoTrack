import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/features/rewards/models/achievement_model.dart';
import 'package:ecotrack/features/rewards/models/user_achievement_model.dart';
import 'package:ecotrack/features/rewards/screens/achievements_screen.dart';
import 'package:ecotrack/features/rewards/widgets/achievement_card.dart';

void main() {
  final sampleAchievements = [
    AchievementModel(
      id: 'ach-1',
      title: 'First Step Green',
      description: 'Complete your first eco activity.',
      requirementType: 'first_activity',
      requirementValue: 1,
      iconName: 'leaf',
      createdAt: DateTime(2026, 8, 20),
    ),
    AchievementModel(
      id: 'ach-2',
      title: 'Eco Centurion',
      description: 'Accumulate 100 Eco Points.',
      requirementType: 'points_reached',
      requirementValue: 100,
      iconName: 'star',
      createdAt: DateTime(2026, 8, 20),
    ),
    AchievementModel(
      id: 'ach-3',
      title: 'Master Recycler',
      description: 'Complete 10 waste reduction activities.',
      requirementType: 'category_activity_count',
      requirementValue: 10,
      requirementCategory: 'Waste',
      iconName: 'tree',
      createdAt: DateTime(2026, 8, 20),
    ),
  ];

  final sampleUnlockedMap = {
    'ach-1': UserAchievementModel(
      achievementId: 'ach-1',
      userId: 'user-123',
      unlockedAt: DateTime(2026, 8, 22),
    ),
  };

  group('Achievement Models Tests', () {
    test('AchievementModel toMap and fromMap serialization round-trip', () {
      final achievement = sampleAchievements.first;
      final map = achievement.toMap();

      expect(map['id'], 'ach-1');
      expect(map['title'], 'First Step Green');
      expect(map['requirementType'], 'first_activity');

      final fromMap = AchievementModel.fromMap(map);
      expect(fromMap.id, achievement.id);
      expect(fromMap.title, achievement.title);
      expect(fromMap.requirementValue, achievement.requirementValue);
    });

    test('UserAchievementModel toMap and fromMap serialization round-trip', () {
      final userAch = sampleUnlockedMap['ach-1']!;
      final map = userAch.toMap();

      expect(map['achievementId'], 'ach-1');
      expect(map['status'], 'unlocked');

      final fromMap = UserAchievementModel.fromMap(map);
      expect(fromMap.achievementId, userAch.achievementId);
      expect(fromMap.status, 'unlocked');
    });
  });

  group('AchievementsScreen UI & Tabs Tests', () {
    testWidgets('Renders header summary and badge tabs correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AchievementsScreen(
            initialAchievements: sampleAchievements,
            initialUnlockedMap: sampleUnlockedMap,
          ),
        ),
      );

      expect(find.text('Achievements & Badges'), findsOneWidget);
      expect(find.text('Badges Unlocked'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('All (3)'), findsOneWidget);
      expect(find.text('Unlocked (1)'), findsOneWidget);
      expect(find.text('Locked (2)'), findsOneWidget);

      expect(find.text('First Step Green'), findsOneWidget);
      expect(find.text('Eco Centurion'), findsOneWidget);
      expect(find.text('Master Recycler'), findsOneWidget);
      expect(find.byType(AchievementCard), findsNWidgets(3));
    });

    testWidgets('Switching to Unlocked tab displays only unlocked badges',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AchievementsScreen(
            initialAchievements: sampleAchievements,
            initialUnlockedMap: sampleUnlockedMap,
          ),
        ),
      );

      await tester.tap(find.text('Unlocked (1)'));
      await tester.pumpAndSettle();

      expect(find.text('First Step Green'), findsOneWidget);
      expect(find.text('Unlocked on 2026-08-22'), findsOneWidget);
      expect(find.text('Eco Centurion'), findsNothing);
    });

    testWidgets('Switching to Locked tab displays only locked badges',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AchievementsScreen(
            initialAchievements: sampleAchievements,
            initialUnlockedMap: sampleUnlockedMap,
          ),
        ),
      );

      await tester.tap(find.text('Locked (2)'));
      await tester.pumpAndSettle();

      expect(find.text('Eco Centurion'), findsOneWidget);
      expect(find.text('Master Recycler'), findsOneWidget);
      expect(find.text('First Step Green'), findsNothing);
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
          home: AchievementsScreen(
            initialAchievements: sampleAchievements,
            initialUnlockedMap: sampleUnlockedMap,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AchievementsScreen), findsOneWidget);
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
          home: AchievementsScreen(
            initialAchievements: sampleAchievements,
            initialUnlockedMap: sampleUnlockedMap,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AchievementsScreen), findsOneWidget);
    });
  });
}
