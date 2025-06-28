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

@injectable
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
      emit(BowlingGameLoaded(game: game, currentPins: currentPins));
    });
  }

  Future<void> _onNewGameStarted(
    BowlingNewGameStarted event,
    Emitter<BowlingState> emit,
  ) async {
    emit(BowlingLoading());

    final result = await startNewGame();
    result.fold((failure) => emit(BowlingError(failure.message)), (game) {
      final currentFrame = game.currentFrame;
      final currentPins = currentFrame?.pins ?? _createDefaultPins();
      emit(BowlingGameLoaded(game: game, currentPins: currentPins));
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
        // Determine next state
        bool canRoll = true;
        List<BowlingPin> nextPins = currentState.currentPins;
        String? message;

        if (updatedFrame.isComplete) {
          // Frame is complete, move to next frame or end game
          if (updatedGame.currentFrameIndex < 9) {
            // Move to next frame
            nextPins = _createDefaultPins();
            message = 'Frame ${updatedFrame.frameNumber} complete!';
          } else {
            // Game complete
            canRoll = false;
            message =
                'Game complete! Final score: ${updatedGame.calculateTotalScore()}';
          }
        } else if (pinsKnocked == 10) {
          // Strike - reset pins for next roll in same frame (10th frame only)
          nextPins = _createDefaultPins();
          message = 'Strike!';
        } else {
          // Continue with remaining pins
          message = 'Roll ${updatedFrame.rolls.length + 1}';
        }

        emit(
          BowlingGameLoaded(
            game: updatedGame.copyWith(
              totalScore: updatedGame.calculateTotalScore(),
            ),
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

  List<BowlingPin> _createDefaultPins() {
    return List.generate(10, (index) => BowlingPin(position: index + 1));
  }
}
