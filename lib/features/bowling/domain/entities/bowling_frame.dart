import 'package:equatable/equatable.dart';
import 'bowling_pin.dart';

class BowlingFrame extends Equatable {
  final int frameNumber; // 1-10
  final List<int> rolls; // Max 2 rolls (3 for 10th frame)
  final List<BowlingPin> pins;
  final bool isComplete;
  final DateTime createdAt;

  const BowlingFrame({
    required this.frameNumber,
    this.rolls = const [],
    required this.pins,
    this.isComplete = false,
    required this.createdAt,
  });

  BowlingFrame copyWith({
    int? frameNumber,
    List<int>? rolls,
    List<BowlingPin>? pins,
    bool? isComplete,
    DateTime? createdAt,
  }) {
    return BowlingFrame(
      frameNumber: frameNumber ?? this.frameNumber,
      rolls: rolls ?? this.rolls,
      pins: pins ?? this.pins,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Calculate pins knocked down in current roll
  int get currentRollScore {
    return pins.where((pin) => pin.isKnockedDown).length;
  }

  // Check if it's a strike (all pins down in first roll)
  bool get isStrike {
    return rolls.isNotEmpty && rolls.first == 10;
  }

  // Check if it's a spare (all pins down in two rolls)
  bool get isSpare {
    return rolls.length == 2 && rolls.fold(0, (sum, roll) => sum + roll) == 10;
  }

  // Get frame score (for display purposes)
  int get frameScore {
    return rolls.fold(0, (sum, roll) => sum + roll);
  }

  // Reset all pins to standing position
  BowlingFrame resetPins() {
    final resetPins = pins.map((pin) => pin.reset()).toList();
    return copyWith(pins: resetPins);
  }

  // Add a roll to the frame
  BowlingFrame addRoll(int pinsKnocked) {
    final newRolls = [...rolls, pinsKnocked];
    bool complete = false;

    // Determine if frame is complete
    if (frameNumber == 10) {
      // 10th frame special rules
      if (newRolls.length == 3) {
        complete = true;
      } else if (newRolls.length == 2 &&
          newRolls.first != 10 &&
          newRolls.fold(0, (a, b) => a + b) < 10) {
        complete = true;
      }
    } else {
      // Regular frames
      if (pinsKnocked == 10 || newRolls.length == 2) {
        complete = true;
      }
    }

    return copyWith(rolls: newRolls, isComplete: complete);
  }

  @override
  List<Object?> get props => [frameNumber, rolls, pins, isComplete, createdAt];
}
