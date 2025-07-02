import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final String name;
  final String? avatarPath;

  const ProfileUpdateRequested({required this.name, this.avatarPath});

  @override
  List<Object> get props => [name, avatarPath ?? ''];
}

class GameResultSaved extends ProfileEvent {
  final int finalScore;
  final int strikes;
  final int spares;
  final int totalPins;
  final bool isPerfectGame;

  const GameResultSaved({
    required this.finalScore,
    required this.strikes,
    required this.spares,
    required this.totalPins,
    required this.isPerfectGame,
  });

  @override
  List<Object> get props => [
    finalScore,
    strikes,
    spares,
    totalPins,
    isPerfectGame,
  ];
}
