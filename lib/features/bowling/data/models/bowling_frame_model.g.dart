// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bowling_frame_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BowlingFrameModel _$BowlingFrameModelFromJson(Map<String, dynamic> json) =>
    BowlingFrameModel(
      frameNumber: (json['frameNumber'] as num).toInt(),
      rolls: (json['rolls'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      pins: (json['pins'] as List<dynamic>)
          .map((e) => BowlingPinModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isComplete: json['isComplete'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$BowlingFrameModelToJson(BowlingFrameModel instance) =>
    <String, dynamic>{
      'frameNumber': instance.frameNumber,
      'rolls': instance.rolls,
      'pins': instance.pins,
      'isComplete': instance.isComplete,
      'createdAt': instance.createdAt.toIso8601String(),
    };
