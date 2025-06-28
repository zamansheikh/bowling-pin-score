import 'package:json_annotation/json_annotation.dart';
import 'bowling_pin_model.dart';
import '../../domain/entities/bowling_frame.dart';

part 'bowling_frame_model.g.dart';

@JsonSerializable()
class BowlingFrameModel {
  final int frameNumber;
  final List<int> rolls;
  final List<BowlingPinModel> pins;
  final bool isComplete;
  final DateTime createdAt;

  const BowlingFrameModel({
    required this.frameNumber,
    required this.rolls,
    required this.pins,
    required this.isComplete,
    required this.createdAt,
  });

  factory BowlingFrameModel.fromJson(Map<String, dynamic> json) =>
      _$BowlingFrameModelFromJson(json);

  Map<String, dynamic> toJson() => _$BowlingFrameModelToJson(this);

  factory BowlingFrameModel.fromEntity(BowlingFrame entity) {
    return BowlingFrameModel(
      frameNumber: entity.frameNumber,
      rolls: entity.rolls,
      pins: entity.pins.map((pin) => BowlingPinModel.fromEntity(pin)).toList(),
      isComplete: entity.isComplete,
      createdAt: entity.createdAt,
    );
  }

  BowlingFrame toEntity() {
    return BowlingFrame(
      frameNumber: frameNumber,
      rolls: rolls,
      pins: pins.map((pin) => pin.toEntity()).toList(),
      isComplete: isComplete,
      createdAt: createdAt,
    );
  }
}
