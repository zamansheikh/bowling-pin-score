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

  // Keep current game in memory during session
  BowlingGame? _currentGame;

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
      // Return cached game if it exists
      if (_currentGame != null) {
        return _currentGame!;
      }

      // Try to load existing game from SharedPreferences
      final totalScore = sharedPreferences.getInt('total_score') ?? 0;
      final currentFrame = sharedPreferences.getInt('current_frame') ?? 0;
      final gameComplete = sharedPreferences.getBool('game_complete') ?? false;
      final gameStartedString = sharedPreferences.getString('game_started');
      final gameCompletedString = sharedPreferences.getString('game_completed');

      // If no saved game exists, create and cache a new game
      if (gameStartedString == null) {
        _currentGame = BowlingGame(
          frames: List.generate(10, (index) => _createDefaultFrame(index + 1)),
          startedAt: DateTime.now(),
        );
        return _currentGame!;
      }

      // Load and cache saved game state
      final startedAt = DateTime.parse(gameStartedString);
      final completedAt = gameCompletedString != null
          ? DateTime.parse(gameCompletedString)
          : null;

      // Load frames data (for now, regenerate - in real app you'd save frame data)
      final frames = _loadSavedFrames();

      _currentGame = BowlingGame(
        frames: frames,
        currentFrameIndex: currentFrame,
        totalScore: totalScore,
        isComplete: gameComplete,
        startedAt: startedAt,
        completedAt: completedAt,
      );

      return _currentGame!;
    } catch (e) {
      throw CacheException('Failed to get current game: ${e.toString()}');
    }
  }

  // Helper method to load saved frames (simplified for now)
  List<BowlingFrame> _loadSavedFrames() {
    // For now, create default frames - in a real app you'd save/load frame details
    final frames = <BowlingFrame>[];

    // Add frames (this is simplified - in a real app you'd save actual frame data)
    for (int i = 0; i < 10; i++) {
      frames.add(_createDefaultFrame(i + 1));
    }

    return frames;
  }

  @override
  Future<BowlingGame> startNewGame() async {
    try {
      final newGame = BowlingGame(
        frames: List.generate(10, (index) => _createDefaultFrame(index + 1)),
        startedAt: DateTime.now(),
      );

      // Cache the new game
      _currentGame = newGame;
      await saveGame(newGame);
      return newGame;
    } catch (e) {
      throw CacheException('Failed to start new game: ${e.toString()}');
    }
  }

  @override
  Future<BowlingGame> updateFrame(BowlingFrameModel frame) async {
    try {
      final currentGame = await getCurrentGame();
      final updatedFrames = List<BowlingFrame>.from(currentGame.frames);

      // Update the specific frame
      if (frame.frameNumber <= updatedFrames.length) {
        updatedFrames[frame.frameNumber - 1] = frame.toEntity();
      }

      // Determine frame advancement
      int nextFrameIndex = currentGame.currentFrameIndex;
      bool gameComplete = false;
      final updatedFrame = frame.toEntity();

      // Check if we should advance to next frame
      if (updatedFrame.isComplete && updatedFrame.frameNumber < 10) {
        // Frames 1-9: advance when complete
        nextFrameIndex =
            updatedFrame.frameNumber; // Move to next frame (0-indexed)

        // Add new frame if needed
        if (nextFrameIndex >= updatedFrames.length) {
          final newFrame = BowlingFrame(
            frameNumber: nextFrameIndex + 1,
            pins: List.generate(10, (index) => BowlingPin(position: index + 1)),
            createdAt: DateTime.now(),
          );
          updatedFrames.add(newFrame);
        }
      } else if (updatedFrame.frameNumber == 10 && updatedFrame.isComplete) {
        // 10th frame complete - game over
        gameComplete = true;
        nextFrameIndex = 10;
      } else if (updatedFrame.frameNumber == 10 && !updatedFrame.isComplete) {
        // Stay in 10th frame until truly complete
        nextFrameIndex = 9; // Keep current frame index at 9 (0-indexed)
      }

      final updatedGame = currentGame.copyWith(
        frames: updatedFrames,
        currentFrameIndex: nextFrameIndex,
        isComplete: gameComplete,
        totalScore: _calculateGameScore(updatedFrames),
        completedAt: gameComplete ? DateTime.now() : null,
      );

      // Update cached game
      _currentGame = updatedGame;
      await saveGame(updatedGame);
      return updatedGame;
    } catch (e) {
      throw CacheException('Failed to update frame: ${e.toString()}');
    }
  }

  // Helper method to calculate total game score
  int _calculateGameScore(List<BowlingFrame> frames) {
    int total = 0;

    for (int i = 0; i < frames.length; i++) {
      final frame = frames[i];
      int frameScore = frame.frameScore;

      if (i < 9) {
        // Frames 1-9: Add strike/spare bonuses
        if (frame.isStrike) {
          // Strike: add next two rolls
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
        } else if (frame.isSpare) {
          // Spare: add next roll
          if (i + 1 < frames.length && frames[i + 1].rolls.isNotEmpty) {
            frameScore += frames[i + 1].rolls.first;
          }
        }
      }
      // 10th frame scoring is already included in frame.frameScore

      total += frameScore;
    }

    return total;
  }

  @override
  Future<void> saveGame(BowlingGame game) async {
    try {
      await sharedPreferences.setInt('total_score', game.totalScore);
      await sharedPreferences.setInt('current_frame', game.currentFrameIndex);
      await sharedPreferences.setBool('game_complete', game.isComplete);

      // Save the started date for game continuity
      await sharedPreferences.setString(
        'game_started',
        game.startedAt.toIso8601String(),
      );

      if (game.completedAt != null) {
        await sharedPreferences.setString(
          'game_completed',
          game.completedAt!.toIso8601String(),
        );
      }
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
