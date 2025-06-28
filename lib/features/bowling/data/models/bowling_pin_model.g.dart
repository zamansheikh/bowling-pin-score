// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bowling_pin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BowlingPinModel _$BowlingPinModelFromJson(Map<String, dynamic> json) =>
    BowlingPinModel(
      position: (json['position'] as num).toInt(),
      isKnockedDown: json['isKnockedDown'] as bool,
      knockedDownAt: json['knockedDownAt'] == null
          ? null
          : DateTime.parse(json['knockedDownAt'] as String),
    );

Map<String, dynamic> _$BowlingPinModelToJson(BowlingPinModel instance) =>
    <String, dynamic>{
      'position': instance.position,
      'isKnockedDown': instance.isKnockedDown,
      'knockedDownAt': instance.knockedDownAt?.toIso8601String(),
    };
