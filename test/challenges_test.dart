import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/features/challenges/models/challenge_model.dart';
import 'package:ecotrack/features/challenges/models/challenge_progress_model.dart';
import 'package:ecotrack/features/challenges/screens/challenge_details_screen.dart';
import 'package:ecotrack/features/challenges/screens/challenges_screen.dart';
import 'package:ecotrack/features/challenges/widgets/challenge_card.dart';

void main() {
  final sampleChallenges = [
    ChallengeModel(
      id: 'ch-1',
      title: 'Zero Waste Week',
      description: 'Complete 3 waste reduction activities this week.',
      type: 'category_activity',
      target: 3,
      targetCategory: 'Waste',
      rewardPoints: 50,
      startDate: DateTime(2026, 8, 20),
      endDate: DateTime(2026, 8, 27),
      createdAt: DateTime(2026, 8, 20),
    ),
    ChallengeModel(
      id: 'ch-2',
      title: 'Green Commuter',
      description: 'Choose eco-friendly transportation for 5 days.',
      type: 'category_activity',
      target: 5,
      targetCategory: 'Transport',
      rewardPoints: 100,
      startDate: DateTime(2026, 8, 20),
      endDate: DateTime(2026, 8, 30),
      createdAt: DateTime(2026, 8, 20),
    ),
    ChallengeModel(
      id: 'ch-3',
      title: 'Earth Hour Special',
      description: 'Past environmental event challenge.',
      type: 'activity_count',
      target: 1,
      rewardPoints: 30,
      startDate: DateTime(2026, 8, 1),
      endDate: DateTime(2026, 8, 10), // Expired
      createdAt: DateTime(2026, 8, 1),
    ),
  ];

  final sampleProgressMap = {
    'ch-1': UserChallengeProgressModel(
      challengeId: 'ch-1',
      userId: 'user-123',
      progress: 2,
      target: 3,
      status: 'in_progress',
      startedAt: DateTime(2026, 8, 21),
    ),
    'ch-2': UserChallengeProgressModel(
      challengeId: 'ch-2',
      userId: 'user-123',
      progress: 5,
      target: 5,
      status: 'completed',
      startedAt: DateTime(2026, 8, 20),
      completedAt: DateTime(2026, 8, 22),
      rewardClaimed: true,
    ),
  };

  group('Challenge Models Serialization & Logic Tests', () {
    test('ChallengeModel toMap and fromMap preserves fields faithfully', () {
      final challenge = sampleChallenges.first;
      final map = challenge.toMap();

      expect(map['id'], 'ch-1');
      expect(map['title'], 'Zero Waste Week');
      expect(map['rewardPoints'], 50);
      expect(map['target'], 3);

      final fromMap = ChallengeModel.fromMap(map);
      expect(fromMap.id, challenge.id);
      expect(fromMap.title, challenge.title);
      expect(fromMap.type, challenge.type);
      expect(fromMap.target, challenge.target);
      expect(fromMap.rewardPoints, challenge.rewardPoints);
    });

    test('UserChallengeProgressModel computes progress percentage accurately', () {
      final progress = sampleProgressMap['ch-1']!;
      expect(progress.progressPercentage, closeTo(2 / 3, 0.01));
      expect(progress.isCompleted, isFalse);

      final completedProgress = sampleProgressMap['ch-2']!;
      expect(completedProgress.progressPercentage, 1.0);
      expect(completedProgress.isCompleted, isTrue);
    });
  });

  group('ChallengesScreen UI & Tabs Tests', () {
    testWidgets('Renders Tabs and Challenge cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChallengesScreen(
            initialChallenges: sampleChallenges,
            initialProgressMap: sampleProgressMap,
          ),
        ),
      );

      expect(find.text('Eco Challenges'), findsOneWidget);
      expect(find.text('Active (1)'), findsOneWidget);
      expect(find.text('Completed (1)'), findsOneWidget);
      expect(find.text('Expired (1)'), findsOneWidget);

      // Active tab shows Zero Waste Week
      expect(find.text('Zero Waste Week'), findsOneWidget);
      expect(find.text('+50 pts'), findsOneWidget);
      expect(find.text('2 / 3 Completed'), findsOneWidget);
      expect(find.byType(ChallengeCard), findsOneWidget);
    });

    testWidgets('Switching to Completed tab shows completed challenges',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChallengesScreen(
            initialChallenges: sampleChallenges,
            initialProgressMap: sampleProgressMap,
          ),
        ),
      );

      await tester.tap(find.text('Completed (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Green Commuter'), findsOneWidget);
      expect(find.text('Completed 🎉'), findsOneWidget);
      expect(find.text('Reward Claimed'), findsOneWidget);
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
          home: ChallengesScreen(
            initialChallenges: sampleChallenges,
            initialProgressMap: sampleProgressMap,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ChallengesScreen), findsOneWidget);
    });
  });

  group('ChallengeDetailsScreen Tests', () {
    testWidgets('Displays complete challenge requirements and progress',
        (WidgetTester tester) async {
      final challenge = sampleChallenges.first;
      final progress = sampleProgressMap['ch-1'];

      await tester.pumpWidget(
        MaterialApp(
          home: ChallengeDetailsScreen(
            initialChallenge: challenge,
            initialProgress: progress,
          ),
        ),
      );

      expect(find.text('Challenge Details'), findsOneWidget);
      expect(find.text('Zero Waste Week'), findsOneWidget);
      expect(find.text('+50 pts'), findsOneWidget);
      expect(find.text('Your Progress'), findsOneWidget);
      expect(find.text('2 / 3 completed'), findsOneWidget);
      expect(find.text('66%'), findsOneWidget);
      expect(find.text('About This Challenge'), findsOneWidget);
      expect(find.text('Challenge Duration'), findsOneWidget);
    });

    testWidgets('Renders completed challenge banner on Details screen',
        (WidgetTester tester) async {
      final challenge = sampleChallenges[1];
      final progress = sampleProgressMap['ch-2'];

      await tester.pumpWidget(
        MaterialApp(
          home: ChallengeDetailsScreen(
            initialChallenge: challenge,
            initialProgress: progress,
          ),
        ),
      );

      expect(find.text('Green Commuter'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(
        find.text(
          'Challenge Complete! Reward points have been credited to your profile.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Renders Challenge Details with 0 overflow on small screen (320x568)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ChallengeDetailsScreen(
            initialChallenge: sampleChallenges.first,
            initialProgress: sampleProgressMap['ch-1'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ChallengeDetailsScreen), findsOneWidget);
    });
  });
}
