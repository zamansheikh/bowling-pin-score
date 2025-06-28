import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/bowling_pin.dart';

part 'bowling_pin_model.g.dart';

@JsonSerializable()
class BowlingPinModel {
  final int position;
  final bool isKnockedDown;
  final DateTime? knockedDownAt;

  const BowlingPinModel({
    required this.position,
    required this.isKnockedDown,
    this.knockedDownAt,
  });

  factory BowlingPinModel.fromJson(Map<String, dynamic> json) =>
      _$BowlingPinModelFromJson(json);

  Map<String, dynamic> toJson() => _$BowlingPinModelToJson(this);

  factory BowlingPinModel.fromEntity(BowlingPin entity) {
    return BowlingPinModel(
      position: entity.position,
      isKnockedDown: entity.isKnockedDown,
      knockedDownAt: entity.knockedDownAt,
    );
  }

  BowlingPin toEntity() {
    return BowlingPin(
      position: position,
      isKnockedDown: isKnockedDown,
      knockedDownAt: knockedDownAt,
    );
  }
}
