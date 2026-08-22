import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/features/leaderboard/models/leaderboard_user_model.dart';
import 'package:ecotrack/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:ecotrack/features/leaderboard/widgets/leaderboard_user_tile.dart';
import 'package:ecotrack/features/leaderboard/widgets/top_three_podium.dart';

void main() {
  final sampleUsers = [
    const LeaderboardUserModel(
      uid: 'user-1',
      fullName: 'Alice Green',
      ecoPoints: 450,
      level: 5,
      rank: 1,
    ),
    const LeaderboardUserModel(
      uid: 'user-2',
      fullName: 'Bob River',
      ecoPoints: 320,
      level: 4,
      rank: 2,
    ),
    const LeaderboardUserModel(
      uid: 'user-3',
      fullName: 'Charlie Forest',
      ecoPoints: 210,
      level: 3,
      rank: 3,
    ),
    const LeaderboardUserModel(
      uid: 'user-4',
      fullName: 'David Solar',
      ecoPoints: 150,
      level: 2,
      rank: 4,
    ),
  ];

  group('LeaderboardUserModel Tests', () {
    test('fromMap creates valid LeaderboardUserModel instance', () {
      final user = LeaderboardUserModel.fromMap(
        {
          'fullName': 'Elena Earth',
          'ecoPoints': 500,
          'level': 6,
        },
        uid: 'user-99',
        rank: 1,
      );

      expect(user.uid, 'user-99');
      expect(user.fullName, 'Elena Earth');
      expect(user.ecoPoints, 500);
      expect(user.level, 6);
      expect(user.rank, 1);
    });
  });

  group('LeaderboardScreen UI & Podium Tests', () {
    testWidgets('Renders Top 3 Podium and ranked list correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LeaderboardScreen(
            initialUsers: sampleUsers,
          ),
        ),
      );

      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('Overall'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);

      // Top 3 Podium
      expect(find.byType(TopThreePodium), findsOneWidget);
      expect(find.text('Alice Green'), findsOneWidget);
      expect(find.text('Bob River'), findsOneWidget);
      expect(find.text('Charlie Forest'), findsOneWidget);

      // 4th place ranked list tile
      expect(find.byType(LeaderboardUserTile), findsOneWidget);
      expect(find.text('David Solar'), findsOneWidget);
      expect(find.text('#4'), findsOneWidget);
      expect(find.text('150 pts'), findsOneWidget);
    });

    testWidgets('Switching to Weekly tab displays periodic notice',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LeaderboardScreen(
            initialUsers: sampleUsers,
          ),
        ),
      );

      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      expect(find.text('Weekly Leaderboard'), findsOneWidget);
      expect(
        find.text(
          'Weekly rankings will be tabulated at the conclusion of the active cycle.',
        ),
        findsOneWidget,
      );
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
          home: LeaderboardScreen(
            initialUsers: sampleUsers,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(LeaderboardScreen), findsOneWidget);
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
          home: LeaderboardScreen(
            initialUsers: sampleUsers,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(LeaderboardScreen), findsOneWidget);
    });
  });
}
