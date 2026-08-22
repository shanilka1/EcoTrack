import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/core/utils/debouncer.dart';
import 'package:ecotrack/features/activities/models/activity_filter_model.dart';
import 'package:ecotrack/features/activities/models/eco_activity_model.dart';
import 'package:ecotrack/features/activities/screens/activities_screen.dart';
import 'package:ecotrack/features/challenges/models/challenge_filter_model.dart';
import 'package:ecotrack/features/challenges/models/challenge_model.dart';
import 'package:ecotrack/features/challenges/models/challenge_progress_model.dart';
import 'package:ecotrack/features/challenges/screens/challenges_screen.dart';

void main() {
  final sampleActivities = [
    EcoActivityModel(
      id: 'act-1',
      title: 'Plant a Native Tree',
      description: 'Plant a fruit or shade tree sapling.',
      category: 'Nature',
      points: 50,
      environmentalBenefit: 'Absorbs CO2',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    EcoActivityModel(
      id: 'act-2',
      title: 'Compost Kitchen Scraps',
      description: 'Collect fruit and vegetable peels for compost.',
      category: 'Waste',
      points: 15,
      environmentalBenefit: 'Reduces landfill methane',
      isActive: true,
      createdAt: DateTime(2026, 1, 2),
    ),
    EcoActivityModel(
      id: 'act-3',
      title: 'Use Reusable Water Bottle',
      description: 'Avoid single-use plastic bottles today.',
      category: 'Water',
      points: 10,
      environmentalBenefit: 'Reduces plastic waste',
      isActive: true,
      createdAt: DateTime(2026, 1, 3),
    ),
  ];

  final sampleChallenges = [
    ChallengeModel(
      id: 'chal-1',
      title: 'Plastic-Free Week',
      description: 'Log 5 waste reduction activities.',
      type: 'category_activity',
      targetCategory: 'Waste',
      target: 5,
      rewardPoints: 100,
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 10)),
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ChallengeModel(
      id: 'chal-2',
      title: 'Century Pioneer',
      description: 'Complete 100 eco activities across all categories.',
      type: 'activity_count',
      target: 100,
      rewardPoints: 500,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 25)),
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];

  group('Debouncer Tests', () {
    test('Debounces rapid calls and executes only the last action', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      int callCount = 0;

      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);

      expect(callCount, 0);

      await Future.delayed(const Duration(milliseconds: 80));
      expect(callCount, 1);

      debouncer.dispose();
    });
  });

  group('ActivityFilterModel Unit Tests', () {
    test('Filters by title, description and category query', () {
      final filter = const ActivityFilterModel(searchQuery: 'plastic');
      final result = filter.apply(sampleActivities);

      expect(result.length, 1);
      expect(result.first.title, 'Use Reusable Water Bottle');
    });

    test('Filters by specific category', () {
      final filter = const ActivityFilterModel(selectedCategory: 'Nature');
      final result = filter.apply(sampleActivities);

      expect(result.length, 1);
      expect(result.first.category, 'Nature');
    });

    test('Filters by points range', () {
      final filter = const ActivityFilterModel(
        pointsFilter: PointsRangeFilter.low, // 1 - 20 pts
      );
      final result = filter.apply(sampleActivities);

      expect(result.length, 2);
      expect(result.any((a) => a.points > 20), isFalse);
    });
  });

  group('ChallengeFilterModel Unit Tests', () {
    test('Filters by search query', () {
      final filter = const ChallengeFilterModel(searchQuery: 'Pioneer');
      final result = filter.apply(sampleChallenges);

      expect(result.length, 1);
      expect(result.first.title, 'Century Pioneer');
    });

    test('Filters by challenge type', () {
      final filter = const ChallengeFilterModel(typeFilter: 'category_activity');
      final result = filter.apply(sampleChallenges);

      expect(result.length, 1);
      expect(result.first.title, 'Plastic-Free Week');
    });

    test('Filters by completed status', () {
      final userProgress = {
        'chal-1': UserChallengeProgressModel(
          challengeId: 'chal-1',
          userId: 'user-1',
          progress: 5,
          target: 5,
          status: 'completed',
          startedAt: DateTime.now(),
          rewardClaimed: true,
        ),
      };

      final filter =
          const ChallengeFilterModel(statusFilter: ChallengeStatusFilter.completed);
      final result =
          filter.apply(sampleChallenges, userProgressMap: userProgress);

      expect(result.length, 1);
      expect(result.first.id, 'chal-1');
    });
  });

  group('ActivitiesScreen Search & Filter Widget Tests', () {
    testWidgets('Search input filters activities dynamically',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActivitiesScreen(
            initialActivities: sampleActivities,
          ),
        ),
      );

      expect(find.text('Plant a Native Tree'), findsOneWidget);
      expect(find.text('Compost Kitchen Scraps'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Compost');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Compost Kitchen Scraps'), findsOneWidget);
      expect(find.text('Plant a Native Tree'), findsNothing);
    });

    testWidgets('Displays professional empty state when no activities match',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActivitiesScreen(
            initialActivities: sampleActivities,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'NonExistentXYZ');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('No matching activities found'), findsOneWidget);
      expect(find.text('Clear Filters'), findsOneWidget);

      // Tap clear filters
      await tester.tap(find.text('Clear Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Plant a Native Tree'), findsOneWidget);
    });
  });

  group('ChallengesScreen Search & Filter Widget Tests', () {
    testWidgets('Search input filters challenges',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChallengesScreen(
            initialChallenges: sampleChallenges,
          ),
        ),
      );

      expect(find.text('Plastic-Free Week'), findsOneWidget);
      expect(find.text('Century Pioneer'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Pioneer');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Century Pioneer'), findsOneWidget);
      expect(find.text('Plastic-Free Week'), findsNothing);
    });
  });

  group('Responsive Layout Tests for Search & Filter UI', () {
    testWidgets('ActivitiesScreen renders on small mobile (320x568) with 0 overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ActivitiesScreen(
            initialActivities: sampleActivities,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('ChallengesScreen renders on tablet (800x1280) with 0 overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ChallengesScreen(
            initialChallenges: sampleChallenges,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
