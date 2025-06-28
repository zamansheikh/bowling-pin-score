// Quick test to verify data layer reset functionality
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/features/bowling/data/datasources/bowling_local_data_source_impl.dart';

void main() {
  group('BowlingLocalDataSource Reset Tests', () {
    late BowlingLocalDataSourceImpl dataSource;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      dataSource = BowlingLocalDataSourceImpl(prefs);
    });

    test('should start with fresh game', () async {
      final game = await dataSource.getCurrentGame();

      expect(game.totalScore, 0);
      expect(game.currentFrameIndex, 0);
      expect(game.isComplete, false);
      expect(game.frames.length, 10);
    });

    test('should completely reset on startNewGame', () async {
      // First, get a game and simulate some progress
      final firstGame = await dataSource.getCurrentGame();

      // Create a modified game with some score
      final modifiedGame = firstGame.copyWith(
        totalScore: 150,
        currentFrameIndex: 5,
      );
      await dataSource.saveGame(modifiedGame);

      // Verify the game was saved
      final savedGame = await dataSource.getCurrentGame();
      expect(savedGame.totalScore, 150);
      expect(savedGame.currentFrameIndex, 5);

      // Now start a new game
      final newGame = await dataSource.startNewGame();

      // Verify complete reset
      expect(newGame.totalScore, 0);
      expect(newGame.currentFrameIndex, 0);
      expect(newGame.isComplete, false);

      // Verify the reset persists
      final reloadedGame = await dataSource.getCurrentGame();
      expect(reloadedGame.totalScore, 0);
      expect(reloadedGame.currentFrameIndex, 0);
    });

    test('should handle force reset properly', () async {
      // Create some data
      final game = await dataSource.getCurrentGame();
      final modifiedGame = game.copyWith(totalScore: 200);
      await dataSource.saveGame(modifiedGame);

      // Force reset
      await dataSource.forceResetGameData();

      // Should get fresh game
      final freshGame = await dataSource.getCurrentGame();
      expect(freshGame.totalScore, 0);
      expect(freshGame.currentFrameIndex, 0);
    });
  });
}
