import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/bowling_game.dart';
import '../../domain/entities/bowling_pin.dart';
import '../../domain/usecases/get_current_game.dart';
import '../../domain/usecases/start_new_game.dart';
import '../../domain/usecases/update_frame.dart';

part 'bowling_event.dart';
part 'bowling_state.dart';

@Injectable()
class BowlingBloc extends Bloc<BowlingEvent, BowlingState> {
  final GetCurrentGame getCurrentGame;
  final StartNewGame startNewGame;
  final UpdateFrame updateFrame;

  BowlingBloc({
    required this.getCurrentGame,
    required this.startNewGame,
    required this.updateFrame,
  }) : super(BowlingInitial()) {
    on<BowlingGameStarted>(_onGameStarted);
    on<BowlingNewGameStarted>(_onNewGameStarted);
    on<BowlingPinTapped>(_onPinTapped);
    on<BowlingRollCompleted>(_onRollCompleted);
    on<BowlingFrameReset>(_onFrameReset);
    on<BowlingGameReset>(_onGameReset);
    on<BowlingAllPinsKnocked>(_onAllPinsKnocked);
    on<BowlingAllPinsReset>(_onAllPinsReset);
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

      emit(currentState.copyWith(currentPins: updatedPins));
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

      // Count knocked down pins
      final pinsKnocked = currentState.currentPins
          .where((pin) => pin.isKnockedDown)
          .length;

      // Update frame with new roll
      final updatedFrame = currentFrame
          .copyWith(pins: currentState.currentPins)
          .addRoll(pinsKnocked);

      final result = await updateFrame(updatedFrame);
      result.fold((failure) => emit(BowlingError(failure.message)), (
        updatedGame,
      ) {
        // Use the frame index from the updated game (data source handles advancement)
        final currentFrameIndex = updatedGame.currentFrameIndex;
        final isGameComplete = updatedGame.isComplete;

        // Determine next state based on updated game
        bool canRoll = !isGameComplete;
        List<BowlingPin> nextPins;
        String? message;

        if (isGameComplete) {
          // Game is complete
          nextPins = currentState.currentPins;
          canRoll = false;
          message =
              'Game complete! Final score: ${updatedGame.calculateTotalScore()}';
        } else if (currentFrameIndex > game.currentFrameIndex) {
          // Frame advanced - get new pins for next frame
          nextPins = _createDefaultPins();
          if (pinsKnocked == 10) {
            message = 'Strike! Moving to Frame ${currentFrameIndex + 1}';
          } else {
            message =
                'Frame ${game.currentFrameIndex + 1} complete! Moving to Frame ${currentFrameIndex + 1}';
          }
        } else if (pinsKnocked == 10 && updatedFrame.frameNumber == 10) {
          // Strike in 10th frame - reset pins for next roll in same frame
          nextPins = _createDefaultPins();
          message = 'Strike! Continue rolling in Frame 10';
        } else if (updatedFrame.isSpare) {
          // Spare - wait for next frame advancement or 10th frame bonus
          nextPins = _createDefaultPins();
          message = 'Spare! Nice shot!';
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
    }
  }

  Future<void> _onAllPinsReset(
    BowlingAllPinsReset event,
    Emitter<BowlingState> emit,
  ) async {
    if (state is BowlingGameLoaded) {
      final currentState = state as BowlingGameLoaded;

      if (!currentState.canRoll) return;

      // Set all pins to standing (Miss/Gutter ball)
      final resetPins = currentState.currentPins
          .map((pin) => pin.reset())
          .toList();

      emit(
        currentState.copyWith(
          currentPins: resetPins,
          message: 'Miss - Gutter ball',
        ),
      );
    }
  }

  List<BowlingPin> _createDefaultPins() {
    return List.generate(10, (index) => BowlingPin(position: index + 1));
  }
}
