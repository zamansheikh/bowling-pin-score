import 'package:equatable/equatable.dart';

class BowlingPin extends Equatable {
  final int position; // 1-10 for pin positions
  final bool isKnockedDown;
  final DateTime? knockedDownAt;

  const BowlingPin({
    required this.position,
    this.isKnockedDown = false,
    this.knockedDownAt,
  });

  BowlingPin copyWith({
    int? position,
    bool? isKnockedDown,
    DateTime? knockedDownAt,
  }) {
    return BowlingPin(
      position: position ?? this.position,
      isKnockedDown: isKnockedDown ?? this.isKnockedDown,
      knockedDownAt: knockedDownAt ?? this.knockedDownAt,
    );
  }

  BowlingPin knockDown() {
    return copyWith(isKnockedDown: true, knockedDownAt: DateTime.now());
  }

  BowlingPin reset() {
    return copyWith(isKnockedDown: false, knockedDownAt: null);
  }

  @override
  List<Object?> get props => [position, isKnockedDown, knockedDownAt];
}
