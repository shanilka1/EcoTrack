import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/features/progress/models/user_statistics_model.dart';
import 'package:ecotrack/features/progress/screens/progress_screen.dart';
import 'package:ecotrack/features/progress/widgets/category_breakdown_card.dart';
import 'package:ecotrack/features/progress/widgets/stat_summary_card.dart';
import 'package:ecotrack/features/progress/widgets/weekly_activity_chart.dart';

void main() {
  const sampleStats = UserStatisticsModel(
    totalEcoPoints: 350,
    level: 4,
    totalActivitiesCompleted: 12,
    completedChallengesCount: 2,
    unlockedAchievementsCount: 3,
    weeklyDailyCounts: {
      'Mon': 2,
      'Tue': 1,
      'Wed': 3,
      'Thu': 0,
      'Fri': 2,
      'Sat': 1,
      'Sun': 0,
    },
    weeklyDailyPoints: {
      'Mon': 30,
      'Tue': 15,
      'Wed': 45,
      'Thu': 0,
      'Fri': 30,
      'Sat': 15,
      'Sun': 0,
    },
    categoryCounts: {
      'Waste': 6,
      'Energy': 4,
      'Transport': 2,
    },
    categoryPercentages: {
      'Waste': 0.50,
      'Energy': 0.33,
      'Transport': 0.17,
    },
    monthlyCounts: {
      'Aug 2026': 12,
    },
  );

  group('UserStatisticsModel Tests', () {
    test('Correctly computes aggregate getters', () {
      expect(sampleStats.hasActivity, isTrue);
      expect(sampleStats.weeklyTotalActivities, 9);
      expect(sampleStats.weeklyTotalPoints, 135);

      final emptyStats = UserStatisticsModel.empty();
      expect(emptyStats.hasActivity, isFalse);
      expect(emptyStats.weeklyTotalActivities, 0);
      expect(emptyStats.weeklyTotalPoints, 0);
    });
  });

  group('ProgressScreen UI & Chart Tests', () {
    testWidgets('Renders all KPI summary cards and chart components',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ProgressScreen(initialStats: sampleStats),
        ),
      );

      expect(find.text('My Progress'), findsOneWidget);

      // KPI Metric cards
      expect(find.byType(StatSummaryCard), findsNWidgets(4));
      expect(find.text('350'), findsOneWidget);
      expect(find.text('12'), findsWidgets);
      expect(find.text('2'), findsWidgets);
      expect(find.text('3'), findsWidgets);

      // Weekly Activity Chart
      expect(find.byType(WeeklyActivityChart), findsOneWidget);
      expect(find.text('Weekly Activity'), findsOneWidget);
      expect(find.text('9 activities this week'), findsOneWidget);
      expect(find.text('+135 pts'), findsOneWidget);

      // Category Breakdown Card
      expect(find.byType(CategoryBreakdownCard), findsOneWidget);
      expect(find.text('Impact by Category'), findsOneWidget);
      expect(find.text('Waste'), findsOneWidget);
      expect(find.text('6 activities (50%)'), findsOneWidget);
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('4 activities (33%)'), findsOneWidget);

      // Monthly Milestones
      expect(find.text('Monthly Milestones'), findsOneWidget);
      expect(find.text('Aug 2026'), findsOneWidget);
    });

    testWidgets('Renders clean empty state when user has 0 activities',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProgressScreen(initialStats: UserStatisticsModel.empty()),
        ),
      );

      expect(find.text('No Activity Recorded Yet'), findsOneWidget);
      expect(find.text('Explore Activities'), findsOneWidget);
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
          home: ProgressScreen(initialStats: sampleStats),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ProgressScreen), findsOneWidget);
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
          home: ProgressScreen(initialStats: sampleStats),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ProgressScreen), findsOneWidget);
    });
  });
}
