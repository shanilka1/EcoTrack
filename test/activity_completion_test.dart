import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/core/utils/level_calculator.dart';
import 'package:ecotrack/features/activities/models/activity_completion_model.dart';

void main() {
  group('LevelCalculator Domain Tests', () {
    test('calculateLevel derives level correctly from eco points', () {
      expect(LevelCalculator.calculateLevel(0), 1);
      expect(LevelCalculator.calculateLevel(50), 1);
      expect(LevelCalculator.calculateLevel(100), 2);
      expect(LevelCalculator.calculateLevel(199), 2);
      expect(LevelCalculator.calculateLevel(200), 3);
      expect(LevelCalculator.calculateLevel(450), 5);
      expect(LevelCalculator.calculateLevel(1000), 11);
    });

    test('pointsToNextLevel calculates remainder accurately', () {
      expect(LevelCalculator.pointsToNextLevel(0), 100);
      expect(LevelCalculator.pointsToNextLevel(75), 25);
      expect(LevelCalculator.pointsToNextLevel(150), 50);
      expect(LevelCalculator.pointsToNextLevel(200), 100);
    });

    test('calculateLevelProgress returns clamped 0.0 to 1.0 progression', () {
      expect(LevelCalculator.calculateLevelProgress(0), 0.0);
      expect(LevelCalculator.calculateLevelProgress(50), 0.5);
      expect(LevelCalculator.calculateLevelProgress(125), 0.25);
      expect(LevelCalculator.calculateLevelProgress(299), 0.99);
    });

    test('getTierName maps levels to rank titles', () {
      expect(LevelCalculator.getTierName(1), 'Eco Explorer');
      expect(LevelCalculator.getTierName(2), 'Eco Explorer');
      expect(LevelCalculator.getTierName(3), 'Eco Enthusiast');
      expect(LevelCalculator.getTierName(5), 'Green Guardian');
      expect(LevelCalculator.getTierName(10), 'Eco Master');
    });
  });

  group('ActivityCompletionModel Serialization Tests', () {
    test('formatDateKey formats dates as YYYY-MM-DD', () {
      final date = DateTime(2026, 8, 22);
      expect(ActivityCompletionModel.formatDateKey(date), '2026-08-22');

      final dateSingleDigit = DateTime(2026, 1, 5);
      expect(ActivityCompletionModel.formatDateKey(dateSingleDigit), '2026-01-05');
    });

    test('generateCompletionId generates deterministic daily document ID', () {
      final date = DateTime(2026, 8, 22);
      final id = ActivityCompletionModel.generateCompletionId('act-123', date);
      expect(id, 'act-123_2026-08-22');
    });

    test('toMap and fromMap preserves all completion fields accurately', () {
      final completion = ActivityCompletionModel(
        id: 'act-123_2026-08-22',
        activityId: 'act-123',
        userId: 'user-456',
        activityTitle: 'Use Reusable Water Bottle',
        category: 'Waste',
        pointsAwarded: 15,
        completedAt: DateTime(2026, 8, 22, 11, 0, 0),
        completionDate: '2026-08-22',
      );

      final map = completion.toMap();
      expect(map['id'], 'act-123_2026-08-22');
      expect(map['activityId'], 'act-123');
      expect(map['userId'], 'user-456');
      expect(map['pointsAwarded'], 15);
      expect(map['completionDate'], '2026-08-22');

      final fromMap = ActivityCompletionModel.fromMap(map);
      expect(fromMap.id, completion.id);
      expect(fromMap.activityId, completion.activityId);
      expect(fromMap.userId, completion.userId);
      expect(fromMap.pointsAwarded, 15);
      expect(fromMap.completionDate, '2026-08-22');
    });

    test('ActivityCompletionResult factory constructors initialize state correctly', () {
      final success = ActivityCompletionResult.success(
        pointsAwarded: 25,
        newTotalPoints: 125,
        newLevel: 2,
      );
      expect(success.isSuccess, isTrue);
      expect(success.pointsAwarded, 25);
      expect(success.newTotalPoints, 125);
      expect(success.newLevel, 2);

      final duplicate = ActivityCompletionResult.alreadyCompleted();
      expect(duplicate.isSuccess, isFalse);
      expect(duplicate.isAlreadyCompletedToday, isTrue);
      expect(duplicate.errorMessage, contains('already completed'));

      final failure = ActivityCompletionResult.failure('Network connection timed out');
      expect(failure.isSuccess, isFalse);
      expect(failure.errorMessage, 'Network connection timed out');
    });
  });
}
