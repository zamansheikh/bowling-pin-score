// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameRecordModel _$GameRecordModelFromJson(Map<String, dynamic> json) =>
    GameRecordModel(
      id: json['id'] as String,
      score: (json['score'] as num).toInt(),
      strikes: (json['strikes'] as num).toInt(),
      spares: (json['spares'] as num).toInt(),
      totalPins: (json['totalPins'] as num).toInt(),
      isPerfectGame: json['isPerfectGame'] as bool,
      playedAt: json['playedAt'] as String,
      frameScores: (json['frameScores'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      gameDurationMs: (json['gameDurationMs'] as num).toInt(),
    );

Map<String, dynamic> _$GameRecordModelToJson(GameRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'score': instance.score,
      'strikes': instance.strikes,
      'spares': instance.spares,
      'totalPins': instance.totalPins,
      'isPerfectGame': instance.isPerfectGame,
      'playedAt': instance.playedAt,
      'frameScores': instance.frameScores,
      'gameDurationMs': instance.gameDurationMs,
    };
