part of 'bowling_bloc.dart';

abstract class BowlingState extends Equatable {
  const BowlingState();

  @override
  List<Object> get props => [];
}

class BowlingInitial extends BowlingState {}

class BowlingLoading extends BowlingState {}

class BowlingGameLoaded extends BowlingState {
  final BowlingGame game;
  final List<BowlingPin> currentPins;
  final bool canRoll;
  final String? message;

  const BowlingGameLoaded({
    required this.game,
    required this.currentPins,
    this.canRoll = true,
    this.message,
  });

  BowlingGameLoaded copyWith({
    BowlingGame? game,
    List<BowlingPin>? currentPins,
    bool? canRoll,
    String? message,
  }) {
    return BowlingGameLoaded(
      game: game ?? this.game,
      currentPins: currentPins ?? this.currentPins,
      canRoll: canRoll ?? this.canRoll,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [game, currentPins, canRoll];
}

class BowlingError extends BowlingState {
  final String message;

  const BowlingError(this.message);

  @override
  List<Object> get props => [message];
}
