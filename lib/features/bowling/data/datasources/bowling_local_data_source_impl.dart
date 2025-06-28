import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/bowling_frame_model.dart';
import '../../domain/entities/bowling_game.dart';
import '../../domain/entities/bowling_frame.dart';
import '../../domain/entities/bowling_pin.dart';
import 'bowling_local_data_source.dart';

@Injectable(as: BowlingLocalDataSource)
class BowlingLocalDataSourceImpl implements BowlingLocalDataSource {
  final SharedPreferences sharedPreferences;

  BowlingLocalDataSourceImpl(this.sharedPreferences);

  // Helper method to create default pins
  List<BowlingPin> _createDefaultPins() {
    return List.generate(10, (index) => BowlingPin(position: index + 1));
  }

  // Helper method to create default frame
  BowlingFrame _createDefaultFrame(int frameNumber) {
    return BowlingFrame(
      frameNumber: frameNumber,
      pins: _createDefaultPins(),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<BowlingGame> getCurrentGame() async {
    try {
      // For now, return a new game if none exists
      // In a real implementation, you'd load from SharedPreferences
      return BowlingGame(
        frames: List.generate(10, (index) => _createDefaultFrame(index + 1)),
        startedAt: DateTime.now(),
      );
    } catch (e) {
      throw CacheException('Failed to get current game: ${e.toString()}');
    }
  }

  @override
  Future<BowlingGame> startNewGame() async {
    try {
      final newGame = BowlingGame(
        frames: List.generate(10, (index) => _createDefaultFrame(index + 1)),
        startedAt: DateTime.now(),
      );
      await saveGame(newGame);
      return newGame;
    } catch (e) {
      throw CacheException('Failed to start new game: ${e.toString()}');
    }
  }

  @override
  Future<BowlingGame> updateFrame(BowlingFrameModel frame) async {
    try {
      // For now, return the current game with updated frame
      // In a real implementation, you'd update the stored game
      final currentGame = await getCurrentGame();
      final updatedFrames = List<BowlingFrame>.from(currentGame.frames);

      if (frame.frameNumber <= updatedFrames.length) {
        updatedFrames[frame.frameNumber - 1] = frame.toEntity();
      }

      final updatedGame = currentGame.copyWith(
        frames: updatedFrames,
        totalScore: currentGame.calculateTotalScore(),
      );

      await saveGame(updatedGame);
      return updatedGame;
    } catch (e) {
      throw CacheException('Failed to update frame: ${e.toString()}');
    }
  }

  @override
  Future<void> saveGame(BowlingGame game) async {
    try {
      // For now, just store basic info
      // In a real implementation, you'd serialize the entire game
      await sharedPreferences.setInt('total_score', game.totalScore);
      await sharedPreferences.setInt('current_frame', game.currentFrameIndex);
      await sharedPreferences.setBool('game_complete', game.isComplete);
    } catch (e) {
      throw CacheException('Failed to save game: ${e.toString()}');
    }
  }

  @override
  Future<List<BowlingGame>> getGameHistory() async {
    try {
      // For now, return empty list
      // In a real implementation, you'd load game history
      return [];
    } catch (e) {
      throw CacheException('Failed to get game history: ${e.toString()}');
    }
  }
}
