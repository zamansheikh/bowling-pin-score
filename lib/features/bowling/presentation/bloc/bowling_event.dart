part of 'bowling_bloc.dart';

abstract class BowlingEvent extends Equatable {
  const BowlingEvent();

  @override
  List<Object> get props => [];
}

class BowlingGameStarted extends BowlingEvent {}

class BowlingNewGameStarted extends BowlingEvent {}

class BowlingPinTapped extends BowlingEvent {
  final int pinPosition;

  const BowlingPinTapped(this.pinPosition);

  @override
  List<Object> get props => [pinPosition];
}

class BowlingRollCompleted extends BowlingEvent {}

class BowlingFrameReset extends BowlingEvent {}

class BowlingGameReset extends BowlingEvent {}
