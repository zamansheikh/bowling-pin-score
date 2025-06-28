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
  static const String _keyCurrentFrame = 'bowling_current_frame';
  static const String _keyTotalScore = 'bowling_total_score';
  static const String _keyGameComplete = 'bowling_game_complete';
  static const String _keyGameStarted = 'bowling_game_started';
  static const String _keyGameCompleted = 'bowling_game_completed';

  final SharedPreferences sharedPreferences;

  BowlingLocalDataSourceImpl(this.sharedPreferences);

  /// Create a fresh bowling game with default settings
  BowlingGame _createFreshGame() {
    return BowlingGame(
      frames: List.generate(
        10,
        (index) => BowlingFrame(
          frameNumber: index + 1,
          pins: List.generate(10, (i) => BowlingPin(position: i + 1)),
          createdAt: DateTime.now(),
        ),
      ),
      currentFrameIndex: 0,
      totalScore: 0,
      isComplete: false,
      startedAt: DateTime.now(),
    );
  }

  @override
  Future<BowlingGame> getCurrentGame() async {
    try {
      final gameStartedString = sharedPreferences.getString(_keyGameStarted);

      // If no saved game exists, create a new one
      if (gameStartedString == null) {
        return _createFreshGame();
      }

      // Load saved game data
      final currentFrameIndex = sharedPreferences.getInt(_keyCurrentFrame) ?? 0;
      final totalScore = sharedPreferences.getInt(_keyTotalScore) ?? 0;
      final isComplete = sharedPreferences.getBool(_keyGameComplete) ?? false;
      final completedString = sharedPreferences.getString(_keyGameCompleted);

      final startedAt = DateTime.parse(gameStartedString);
      final completedAt = completedString != null
          ? DateTime.parse(completedString)
          : null;

      // Validate data integrity
      if (currentFrameIndex < 0 ||
          currentFrameIndex > 10 ||
          totalScore < 0 ||
          totalScore > 300) {
        // Data is corrupted, start fresh
        await _clearAllGameData();
        return _createFreshGame();
      }

      return BowlingGame(
        frames: _createFramesForSavedGame(currentFrameIndex),
        currentFrameIndex: currentFrameIndex,
        totalScore: totalScore,
        isComplete: isComplete,
        startedAt: startedAt,
        completedAt: completedAt,
      );
    } catch (e) {
      // If there's any error, start fresh
      await _clearAllGameData();
      return _createFreshGame();
    }
  }

  /// Create frames for a saved game (simplified version)
  List<BowlingFrame> _createFramesForSavedGame(int currentFrameIndex) {
    return List.generate(
      10,
      (index) => BowlingFrame(
        frameNumber: index + 1,
        pins: List.generate(10, (i) => BowlingPin(position: i + 1)),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<BowlingGame> startNewGame() async {
    try {
      // First, completely clear all existing data
      await _clearAllGameData();

      // Create a fresh game
      final newGame = _createFreshGame();

      // Save the new game
      await saveGame(newGame);

      return newGame;
    } catch (e) {
      throw CacheException('Failed to start new game: ${e.toString()}');
    }
  }

  @override
  Future<void> forceResetGameData() async {
    await _clearAllGameData();
  }

  /// Clear all bowling-related data from SharedPreferences
  Future<void> _clearAllGameData() async {
    await sharedPreferences.remove(_keyCurrentFrame);
    await sharedPreferences.remove(_keyTotalScore);
    await sharedPreferences.remove(_keyGameComplete);
    await sharedPreferences.remove(_keyGameStarted);
    await sharedPreferences.remove(_keyGameCompleted);

    // Clear any legacy keys that might exist
    await sharedPreferences.remove('total_score');
    await sharedPreferences.remove('current_frame');
    await sharedPreferences.remove('game_complete');
    await sharedPreferences.remove('game_started');
    await sharedPreferences.remove('game_completed');
  }

  @override
  Future<BowlingGame> updateFrame(BowlingFrameModel frameModel) async {
    try {
      // Get current game state
      final currentGame = await getCurrentGame();
      final frame = frameModel.toEntity();

      // Update the specific frame
      final updatedFrames = List<BowlingFrame>.from(currentGame.frames);
      if (frame.frameNumber <= updatedFrames.length) {
        updatedFrames[frame.frameNumber - 1] = frame;
      }

      // Calculate new game state
      final newTotalScore = _calculateTotalScore(updatedFrames);
      int newCurrentFrameIndex = currentGame.currentFrameIndex;
      bool newIsComplete = false;

      // Determine frame progression
      if (frame.isComplete && frame.frameNumber < 10) {
        // Normal frames 1-9: advance to next frame
        newCurrentFrameIndex = frame.frameNumber;
      } else if (frame.frameNumber == 10) {
        // 10th frame logic
        if (frame.isComplete) {
          newIsComplete = true;
          newCurrentFrameIndex = 10;
        } else {
          newCurrentFrameIndex = 9; // Stay on 10th frame
        }
      }

      // Create updated game
      final updatedGame = BowlingGame(
        frames: updatedFrames,
        currentFrameIndex: newCurrentFrameIndex,
        totalScore: newTotalScore,
        isComplete: newIsComplete,
        startedAt: currentGame.startedAt,
        completedAt: newIsComplete ? DateTime.now() : null,
      );

      // Save updated game
      await saveGame(updatedGame);

      return updatedGame;
    } catch (e) {
      throw CacheException('Failed to update frame: ${e.toString()}');
    }
  }

  /// Calculate total score for all completed frames
  int _calculateTotalScore(List<BowlingFrame> frames) {
    int total = 0;

    for (int i = 0; i < frames.length; i++) {
      final frame = frames[i];
      int frameScore = frame.frameScore;

      if (i < 9) {
        // Frames 1-9
        if (frame.isStrike && frame.rolls.isNotEmpty) {
          // Strike: add next two rolls
          frameScore = 10;
          if (i + 1 < frames.length) {
            final nextFrame = frames[i + 1];
            if (nextFrame.rolls.isNotEmpty) {
              frameScore += nextFrame.rolls.first;
              if (nextFrame.rolls.length > 1) {
                frameScore += nextFrame.rolls[1];
              } else if (i + 2 < frames.length &&
                  frames[i + 2].rolls.isNotEmpty) {
                frameScore += frames[i + 2].rolls.first;
              }
            }
          }
        } else if (frame.isSpare && frame.rolls.length >= 2) {
          // Spare: add next roll
          frameScore = 10;
          if (i + 1 < frames.length && frames[i + 1].rolls.isNotEmpty) {
            frameScore += frames[i + 1].rolls.first;
          }
        }
      }
      // For 10th frame, frameScore is already calculated correctly

      total += frameScore;
    }

    return total;
  }

  @override
  Future<void> saveGame(BowlingGame game) async {
    try {
      await sharedPreferences.setInt(_keyCurrentFrame, game.currentFrameIndex);
      await sharedPreferences.setInt(_keyTotalScore, game.totalScore);
      await sharedPreferences.setBool(_keyGameComplete, game.isComplete);
      await sharedPreferences.setString(
        _keyGameStarted,
        game.startedAt.toIso8601String(),
      );

      if (game.completedAt != null) {
        await sharedPreferences.setString(
          _keyGameCompleted,
          game.completedAt!.toIso8601String(),
        );
      }
    } catch (e) {
      throw CacheException('Failed to save game: ${e.toString()}');
    }
  }

  @override
  Future<List<BowlingGame>> getGameHistory() async {
    // For now, return empty list
    // In a real implementation, you'd save/load multiple games
    return [];
  }
}
