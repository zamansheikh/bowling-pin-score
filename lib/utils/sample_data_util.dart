import '../core/services/game_manager.dart';
import '../features/profile/domain/entities/game_record.dart';

/// Utility class to add sample games for testing
class SampleDataUtil {
  /// Add sample games for testing
  static Future<void> addSampleGames() async {
    try {
      // Sample games for different dates
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final threeDaysAgo = today.subtract(const Duration(days: 3));
      final oneWeekAgo = today.subtract(const Duration(days: 7));

      // Today's games
      await GameManager.saveGame(
        GameRecord(
          id: 'sample_1',
          score: 147,
          strikes: 2,
          spares: 5,
          totalPins: 147,
          isPerfectGame: false,
          playedAt: today,
          frameScores: [15, 23, 8, 20, 17, 24, 9, 13, 18, 0],
          gameDuration: const Duration(minutes: 18),
        ),
      );

      await GameManager.saveGame(
        GameRecord(
          id: 'sample_2',
          score: 189,
          strikes: 5,
          spares: 3,
          totalPins: 189,
          isPerfectGame: false,
          playedAt: today.add(const Duration(hours: 2)),
          frameScores: [20, 18, 30, 15, 20, 17, 30, 19, 20, 0],
          gameDuration: const Duration(minutes: 22),
        ),
      );

      // Yesterday's game
      await GameManager.saveGame(
        GameRecord(
          id: 'sample_3',
          score: 165,
          strikes: 3,
          spares: 4,
          totalPins: 165,
          isPerfectGame: false,
          playedAt: yesterday,
          frameScores: [18, 15, 20, 12, 25, 13, 17, 20, 15, 10],
          gameDuration: const Duration(minutes: 20),
        ),
      );

      // Three days ago - multiple games
      await GameManager.saveGame(
        GameRecord(
          id: 'sample_4',
          score: 201,
          strikes: 7,
          spares: 2,
          totalPins: 201,
          isPerfectGame: false,
          playedAt: threeDaysAgo,
          frameScores: [25, 30, 18, 30, 20, 15, 30, 17, 16, 0],
          gameDuration: const Duration(minutes: 25),
        ),
      );

      await GameManager.saveGame(
        GameRecord(
          id: 'sample_5',
          score: 300,
          strikes: 12,
          spares: 0,
          totalPins: 300,
          isPerfectGame: true,
          playedAt: threeDaysAgo.add(const Duration(hours: 1)),
          frameScores: [30, 30, 30, 30, 30, 30, 30, 30, 30, 30],
          gameDuration: const Duration(minutes: 15),
        ),
      );

      // One week ago
      await GameManager.saveGame(
        GameRecord(
          id: 'sample_6',
          score: 132,
          strikes: 1,
          spares: 6,
          totalPins: 132,
          isPerfectGame: false,
          playedAt: oneWeekAgo,
          frameScores: [12, 15, 8, 17, 20, 13, 18, 9, 15, 5],
          gameDuration: const Duration(minutes: 19),
        ),
      );

      print('Sample games added successfully!');
    } catch (e) {
      print('Error adding sample games: $e');
    }
  }

  /// Clear all sample data
  static Future<void> clearAllGames() async {
    try {
      await GameManager.clearAllGames();
      print('All games cleared successfully!');
    } catch (e) {
      print('Error clearing games: $e');
    }
  }
}
