import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/game_manager.dart';
import '../../../profile/domain/entities/game_record.dart';
import '../../domain/entities/bowling_game.dart';
import '../../domain/entities/bowling_pin.dart';
import '../../domain/usecases/get_current_game.dart';
import '../../domain/usecases/start_new_game.dart';
import '../../domain/usecases/update_frame.dart';
import '../../../profile/domain/usecases/save_game_result.dart';

part 'bowling_event.dart';
part 'bowling_state.dart';

@Injectable()
class BowlingBloc extends Bloc<BowlingEvent, BowlingState> {
  final GetCurrentGame getCurrentGame;
  final StartNewGame startNewGame;
  final UpdateFrame updateFrame;
  final SaveGameResult saveGameResult;

  DateTime? _gameDate; // Store the game date

  BowlingBloc({
    required this.getCurrentGame,
    required this.startNewGame,
    required this.updateFrame,
    required this.saveGameResult,
  }) : super(BowlingInitial()) {
    on<BowlingGameStarted>(_onGameStarted);
    on<BowlingNewGameStarted>(_onNewGameStarted);
    on<BowlingPinTapped>(_onPinTapped);
    on<BowlingRollCompleted>(_onRollCompleted);
    on<BowlingFrameReset>(_onFrameReset);
  }

  /// Set the game date for saving the game result
  void setGameDate(DateTime? gameDate) {
    _gameDate = gameDate;
  }

  Future<void> _onGameStarted(
    BowlingGameStarted event,
    Emitter<BowlingState> emit,
  ) async {
    emit(BowlingLoading());

    final result = await getCurrentGame();
    result.fold((failure) => emit(BowlingError(failure.message)), (game) {
      final currentFrame = game.currentFrame;
      final currentPins = currentFrame?.pins ?? _createDefaultPins();
      final bool canRoll = !game.isComplete;
      String? message;

      if (game.isComplete) {
        message = 'Game complete! Start a new game.';
      } else if (game.currentFrameIndex == 0 && game.totalScore == 0) {
        message = 'A new game is ready. Throw the first ball!';
      } else {
        message = 'Welcome back! Continue your game.';
      }

      emit(
        BowlingGameLoaded(
          game: game,
          currentPins: currentPins,
          canRoll: canRoll,
          message: message,
        ),
      );
    });
  }

  Future<void> _onNewGameStarted(
    BowlingNewGameStarted event,
    Emitter<BowlingState> emit,
  ) async {
    emit(BowlingLoading());

    final result = await startNewGame();
    result.fold((failure) => emit(BowlingError(failure.message)), (game) {
      final currentPins = game.currentFrame?.pins ?? _createDefaultPins();
      emit(
        BowlingGameLoaded(
          game: game,
          currentPins: currentPins,
          canRoll: true,
          message: 'New game started! Good luck!',
        ),
      );
    });
  }

  Future<void> _onPinTapped(
    BowlingPinTapped event,
    Emitter<BowlingState> emit,
  ) async {
    if (state is BowlingGameLoaded) {
      final currentState = state as BowlingGameLoaded;

      if (!currentState.canRoll) return;

      // Toggle pin state
      final updatedPins = currentState.currentPins.map((pin) {
        if (pin.position == event.pinPosition) {
          return pin.isKnockedDown ? pin.reset() : pin.knockDown();
        }
        return pin;
      }).toList();

      // Log pin states for debugging
      debugPrint(
        'DEBUG: Pin tapped, position: ${event.pinPosition}, updatedPins: ${updatedPins.map((p) => p.isKnockedDown ? 1 : 0).toList()}',
      );

      // Validate: Ensure no more than 10 pins are knocked down
      final knockedDownCount = updatedPins
          .where((pin) => pin.isKnockedDown)
          .length;
      if (knockedDownCount > 10) {
        debugPrint(
          'DEBUG: Invalid pin state - more than 10 pins knocked down, resetting to default',
        );
        emit(
          currentState.copyWith(
            currentPins: _createDefaultPins(),
            message: 'Error: Too many pins selected, reset pins',
          ),
        );
        return;
      }

      emit(
        currentState.copyWith(
          currentPins: updatedPins,
          message: 'Pin ${event.pinPosition} toggled',
        ),
      );
    }
  }

  Future<void> _onRollCompleted(
    BowlingRollCompleted event,
    Emitter<BowlingState> emit,
  ) async {
    if (state is BowlingGameLoaded) {
      final currentState = state as BowlingGameLoaded;
      final game = currentState.game;
      final currentFrame = game.currentFrame;

      if (currentFrame == null) return;

      // Calculate pins knocked down for this specific roll
      final totalPinsDown = currentState.currentPins
          .where((pin) => pin.isKnockedDown)
          .length;
      debugPrint(
        'DEBUG: totalPinsDown: $totalPinsDown, currentPins: ${currentState.currentPins.map((p) => p.isKnockedDown ? 1 : 0).toList()}',
      );

      // Determine pins knocked down for this roll
      int pinsKnockedThisRoll;
      if (currentFrame.frameNumber == 10) {
        // For 10th frame, handle rolls individually due to pin resets
        pinsKnockedThisRoll = totalPinsDown;
        if (pinsKnockedThisRoll < 0 || pinsKnockedThisRoll > 10) {
          pinsKnockedThisRoll = 0; // Safety check
          debugPrint(
            'DEBUG: Invalid pinsKnockedThisRoll: $totalPinsDown, resetting to 0',
          );
        }
      } else {
        // Non-10th frame: calculate difference from previous rolls
        if (currentFrame.rolls.isEmpty) {
          pinsKnockedThisRoll = totalPinsDown;
        } else {
          final previousTotal = currentFrame.rolls.fold(
            0,
            (sum, roll) => sum + roll,
          );
          pinsKnockedThisRoll = totalPinsDown - previousTotal;
          if (pinsKnockedThisRoll < 0) {
            pinsKnockedThisRoll = 0;
          }
        }
      }
      debugPrint(
        'DEBUG: pinsKnockedThisRoll: $pinsKnockedThisRoll, rolls so far: ${currentFrame.rolls}',
      );

      // Update frame with new roll
      final updatedFrame = currentFrame
          .copyWith(pins: currentState.currentPins)
          .addRoll(pinsKnockedThisRoll);

      final result = await updateFrame(updatedFrame);
      result.fold((failure) => emit(BowlingError(failure.message)), (
        updatedGame,
      ) {
        // Use the frame index from the updated game
        final currentFrameIndex = updatedGame.currentFrameIndex;
        final isGameComplete = updatedGame.isComplete;

        // Determine next state
        bool canRoll = !isGameComplete;
        List<BowlingPin> nextPins;
        String? message;

        if (isGameComplete) {
          // Game is complete
          nextPins = currentState.currentPins;
          canRoll = false;
          final finalScore = updatedGame.calculateTotalScore();
          debugPrint(
            'DEBUG: Game complete! 10th frame rolls: ${updatedGame.frames.length >= 10 ? updatedGame.frames[9].rolls : "N/A"}, finalScore: $finalScore',
          );
          message = 'Game complete! Final score: $finalScore';

          // Calculate game statistics for profile
          int totalStrikes = 0;
          int totalSpares = 0;
          int totalPins = 0;

          for (final frame in updatedGame.frames) {
            if (frame.isStrike) totalStrikes++;
            if (frame.isSpare) totalSpares++;
            totalPins += frame.frameScore;
          }

          // Save game result to profile
          _saveGameResultToStorage(
            finalScore: finalScore,
            strikes: totalStrikes,
            spares: totalSpares,
            totalPins: totalPins,
            isPerfectGame: finalScore == 300,
            gameDate: _gameDate,
          );
        } else if (currentFrameIndex > game.currentFrameIndex) {
          // Frame advanced
          nextPins = _createDefaultPins();
          if (totalPinsDown == 10) {
            message = 'Strike! Moving to Frame ${currentFrameIndex + 1}';
          } else {
            message =
                'Frame ${game.currentFrameIndex + 1} complete! Moving to Frame ${currentFrameIndex + 1}';
          }
        } else if (totalPinsDown == 10 && updatedFrame.frameNumber == 10) {
          // Strike in 10th frame - reset pins for next roll
          nextPins = _createDefaultPins();
          final rollCount = updatedFrame.rolls.length;
          debugPrint(
            'DEBUG: 10th frame strike - rolls: ${updatedFrame.rolls}, rollCount: $rollCount, isComplete: ${updatedFrame.isComplete}',
          );
          if (rollCount == 1) {
            message = 'Strike! Roll ${rollCount + 1} of 3 in Frame 10';
          } else if (rollCount == 2) {
            message = 'Strike! Final roll in Frame 10';
          } else {
            message = 'Strike! Continue rolling in Frame 10';
          }
        } else if (updatedFrame.isSpare && updatedFrame.frameNumber == 10) {
          // Spare in 10th frame - reset pins for bonus roll
          nextPins = _createDefaultPins();
          message = 'Spare! Bonus roll in Frame 10';
        } else if (updatedFrame.frameNumber == 10 &&
            updatedFrame.rolls.length == 2) {
          // After second roll in 10th frame (not a strike or spare), reset pins for third roll
          nextPins = _createDefaultPins();
          message = 'Final roll in Frame 10';
        } else {
          // Continue with remaining pins in same frame
          nextPins = currentState.currentPins;
          message =
              'Roll ${updatedFrame.rolls.length + 1} of Frame ${updatedFrame.frameNumber}';
        }

        emit(
          BowlingGameLoaded(
            game: updatedGame,
            currentPins: nextPins,
            canRoll: canRoll,
            message: message,
          ),
        );
      });
    }
  }

  Future<void> _onFrameReset(
    BowlingFrameReset event,
    Emitter<BowlingState> emit,
  ) async {
    if (state is BowlingGameLoaded) {
      final currentState = state as BowlingGameLoaded;
      final resetPins = _createDefaultPins();

      emit(
        currentState.copyWith(
          currentPins: resetPins,
          canRoll: true,
          message: 'Frame reset',
        ),
      );
    }
  }

  Future<void> _onGameReset(
    BowlingGameReset event,
    Emitter<BowlingState> emit,
  ) async {
    add(BowlingNewGameStarted());
  }

  Future<void> _onAllPinsKnocked(
    BowlingAllPinsKnocked event,
    Emitter<BowlingState> emit,
  ) async {
    if (state is BowlingGameLoaded) {
      final currentState = state as BowlingGameLoaded;

      if (!currentState.canRoll) return;

      // Set all pins to knocked down (Strike)
      final knockedPins = currentState.currentPins
          .map((pin) => pin.knockDown())
          .toList();

      emit(
        currentState.copyWith(
          currentPins: knockedPins,
          message: 'Strike! All pins knocked down',
        ),
      );

      // Automatically complete the roll
      add(BowlingRollCompleted());
    }
  }

  Future<void> _onAllPinsReset(
    BowlingAllPinsReset event,
    Emitter<BowlingState> emit,
  ) async {
    if (state is BowlingGameLoaded) {
      final currentState = state as BowlingGameLoaded;

      if (!currentState.canRoll) return;

      final game = currentState.game;
      final currentFrame = game.currentFrame;

      if (currentFrame == null) return;

      // If this is the first roll of the frame, reset all pins (gutter ball)
      if (currentFrame.rolls.isEmpty) {
        final resetPins = currentState.currentPins
            .map((pin) => pin.reset())
            .toList();

        emit(
          currentState.copyWith(
            currentPins: resetPins,
            message: 'Miss - Gutter ball',
          ),
        );

        // Automatically complete the roll
        add(BowlingRollCompleted());
      } else {
        // If this is not the first roll, preserve the actual pins that were knocked down
        // and only reset the remaining standing pins (miss on remaining pins)
        final resetPins = currentState.currentPins.map((pin) {
          // If the pin is already knocked down, keep it knocked down
          // If the pin is standing, keep it standing (miss on remaining pins)
          return pin.isKnockedDown ? pin : pin.reset();
        }).toList();

        emit(
          currentState.copyWith(
            currentPins: resetPins,
            message: 'Miss - No additional pins knocked down',
          ),
        );

        // Automatically complete the roll
        add(BowlingRollCompleted());
      }
    }
  }

  List<BowlingPin> _createDefaultPins() {
    return List.generate(10, (index) => BowlingPin(position: index + 1));
  }

  /// Save game result to both the profile repository and GameManager
  Future<void> _saveGameResultToStorage({
    required int finalScore,
    required int strikes,
    required int spares,
    required int totalPins,
    required bool isPerfectGame,
    DateTime? gameDate,
  }) async {
    try {
      // Save to the existing profile repository
      final result = await saveGameResult.call(
        finalScore: finalScore,
        strikes: strikes,
        spares: spares,
        totalPins: totalPins,
        isPerfectGame: isPerfectGame,
      );

      // Also save to GameManager for home page statistics
      if (result.isRight()) {
        final now = DateTime.now();
        final gameRecord = GameRecord(
          id: '${now.millisecondsSinceEpoch}', // Simple ID generation
          score: finalScore,
          strikes: strikes,
          spares: spares,
          totalPins: totalPins,
          isPerfectGame: isPerfectGame,
          playedAt: gameDate ?? now,
          frameScores: _calculateFrameScores(),
          gameDuration: Duration(minutes: 15), // Estimate duration
        );

        await GameManager.saveGame(gameRecord);
      }
    } catch (e) {
      debugPrint('Error saving game result: $e');
    }
  }

  /// Calculate individual frame scores from the current game
  List<int> _calculateFrameScores() {
    if (state is BowlingGameLoaded) {
      final game = (state as BowlingGameLoaded).game;
      return game.frames.map((frame) => frame.frameScore).toList();
    }
    return List.generate(10, (index) => 0); // Default empty scores
  }
}
