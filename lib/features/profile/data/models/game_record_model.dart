import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/game_record.dart';

part 'game_record_model.g.dart';

@JsonSerializable()
class GameRecordModel {
  final String id;
  final int score;
  final int strikes;
  final int spares;
  final int totalPins;
  final bool isPerfectGame;
  final String playedAt; // ISO 8601 string
  final List<int> frameScores;
  final int gameDurationMs; // Duration in milliseconds

  const GameRecordModel({
    required this.id,
    required this.score,
    required this.strikes,
    required this.spares,
    required this.totalPins,
    required this.isPerfectGame,
    required this.playedAt,
    required this.frameScores,
    required this.gameDurationMs,
  });

  factory GameRecordModel.fromJson(Map<String, dynamic> json) =>
      _$GameRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$GameRecordModelToJson(this);

  factory GameRecordModel.fromEntity(GameRecord entity) {
    return GameRecordModel(
      id: entity.id,
      score: entity.score,
      strikes: entity.strikes,
      spares: entity.spares,
      totalPins: entity.totalPins,
      isPerfectGame: entity.isPerfectGame,
      playedAt: entity.playedAt.toIso8601String(),
      frameScores: entity.frameScores,
      gameDurationMs: entity.gameDuration.inMilliseconds,
    );
  }

  GameRecord toEntity() {
    return GameRecord(
      id: id,
      score: score,
      strikes: strikes,
      spares: spares,
      totalPins: totalPins,
      isPerfectGame: isPerfectGame,
      playedAt: DateTime.parse(playedAt),
      frameScores: frameScores,
      gameDuration: Duration(milliseconds: gameDurationMs),
    );
  }
}
