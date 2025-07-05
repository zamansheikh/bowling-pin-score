import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bowlingpinscore/core/services/game_manager.dart';
import 'package:bowlingpinscore/features/profile/domain/entities/game_record.dart';

void main() {
  group('GameManager Tests', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and retrieve games by date', () async {
      final testDate = DateTime(2025, 5, 1);
      final gameRecord = GameRecord(
        id: 'test_game_1',
        score: 150,
        strikes: 3,
        spares: 4,
        totalPins: 150,
        isPerfectGame: false,
        playedAt: testDate,
        frameScores: [15, 20, 10, 15, 18, 12, 20, 15, 17, 8],
        gameDuration: const Duration(minutes: 20),
      );

      // Save the game
      await GameManager.saveGame(gameRecord);

      // Retrieve games for the same date
      final retrievedGames = await GameManager.getGamesByDate(testDate);

      expect(retrievedGames.length, 1);
      expect(retrievedGames.first.id, 'test_game_1');
      expect(retrievedGames.first.score, 150);
      expect(retrievedGames.first.strikes, 3);
      expect(retrievedGames.first.spares, 4);
    });

    test('should retrieve today\'s statistics correctly', () async {
      final today = DateTime.now();

      // Add multiple games for today
      await GameManager.saveGame(
        GameRecord(
          id: 'today_1',
          score: 150,
          strikes: 2,
          spares: 5,
          totalPins: 150,
          isPerfectGame: false,
          playedAt: today,
          frameScores: [15, 20, 10, 15, 18, 12, 20, 15, 17, 8],
          gameDuration: const Duration(minutes: 20),
        ),
      );

      await GameManager.saveGame(
        GameRecord(
          id: 'today_2',
          score: 180,
          strikes: 4,
          spares: 3,
          totalPins: 180,
          isPerfectGame: false,
          playedAt: today.add(const Duration(hours: 1)),
          frameScores: [20, 25, 15, 20, 22, 18, 25, 20, 15, 0],
          gameDuration: const Duration(minutes: 22),
        ),
      );

      final stats = await GameManager.getTodaysStats();

      expect(stats['totalGames'], 2);
      expect(stats['averageScore'], 165); // (150 + 180) / 2
      expect(stats['bestScore'], 180);
      expect(stats['totalStrikes'], 6); // 2 + 4
      expect(stats['totalSpares'], 8); // 5 + 3
    });

    test('should group games by date correctly', () async {
      final date1 = DateTime(2025, 5, 1);
      final date2 = DateTime(2025, 5, 2);

      // Add games for different dates
      await GameManager.saveGame(
        GameRecord(
          id: 'game_1',
          score: 150,
          strikes: 2,
          spares: 5,
          totalPins: 150,
          isPerfectGame: false,
          playedAt: date1,
          frameScores: [15, 20, 10, 15, 18, 12, 20, 15, 17, 8],
          gameDuration: const Duration(minutes: 20),
        ),
      );

      await GameManager.saveGame(
        GameRecord(
          id: 'game_2',
          score: 180,
          strikes: 4,
          spares: 3,
          totalPins: 180,
          isPerfectGame: false,
          playedAt: date2,
          frameScores: [20, 25, 15, 20, 22, 18, 25, 20, 15, 0],
          gameDuration: const Duration(minutes: 22),
        ),
      );

      final groupedGames = await GameManager.getGamesByDateGrouped();

      expect(groupedGames.length, 2);

      // Should be sorted by date (newest first)
      expect(groupedGames.first.date, date2);
      expect(groupedGames.last.date, date1);

      expect(groupedGames.first.games.length, 1);
      expect(groupedGames.last.games.length, 1);
    });

    test('should clear all games correctly', () async {
      final testDate = DateTime(2025, 5, 1);
      final gameRecord = GameRecord(
        id: 'test_game',
        score: 150,
        strikes: 3,
        spares: 4,
        totalPins: 150,
        isPerfectGame: false,
        playedAt: testDate,
        frameScores: [15, 20, 10, 15, 18, 12, 20, 15, 17, 8],
        gameDuration: const Duration(minutes: 20),
      );

      // Save the game
      await GameManager.saveGame(gameRecord);

      // Verify it exists
      final gamesBefore = await GameManager.getAllGames();
      expect(gamesBefore.length, 1);

      // Clear all games
      await GameManager.clearAllGames();

      // Verify it's gone
      final gamesAfter = await GameManager.getAllGames();
      expect(gamesAfter.length, 0);
    });
  });
}
