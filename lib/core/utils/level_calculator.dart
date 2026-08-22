/// Pure utility for calculating user level and rank tier based on authoritative eco points
class LevelCalculator {
  LevelCalculator._();

  /// Points required for each level progression step (100 points per level)
  static const int pointsPerLevel = 100;

  /// Calculates level from total eco points (starts at Level 1 with 0 points)
  static int calculateLevel(int ecoPoints) {
    if (ecoPoints <= 0) return 1;
    return 1 + (ecoPoints ~/ pointsPerLevel);
  }

  /// Calculates points needed to reach the next level
  static int pointsToNextLevel(int currentPoints) {
    final currentLevel = calculateLevel(currentPoints);
    final nextLevelThreshold = currentLevel * pointsPerLevel;
    return nextLevelThreshold - currentPoints;
  }

  /// Calculates progress towards next level as a percentage (0.0 to 1.0)
  static double calculateLevelProgress(int currentPoints) {
    if (currentPoints <= 0) return 0.0;
    final currentLevelBase = (calculateLevel(currentPoints) - 1) * pointsPerLevel;
    final pointsInCurrentLevel = currentPoints - currentLevelBase;
    return (pointsInCurrentLevel / pointsPerLevel).clamp(0.0, 1.0);
  }

  /// Returns descriptive rank tier name based on level
  static String getTierName(int level) {
    if (level >= 10) return 'Eco Master';
    if (level >= 5) return 'Green Guardian';
    if (level >= 3) return 'Eco Enthusiast';
    return 'Eco Explorer';
  }
}
