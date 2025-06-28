import 'package:equatable/equatable.dart';
import 'bowling_frame.dart';

class BowlingGame extends Equatable {
  final List<BowlingFrame> frames;
  final int currentFrameIndex;
  final int totalScore;
  final bool isComplete;
  final DateTime startedAt;
  final DateTime? completedAt;

  const BowlingGame({
    this.frames = const [],
    this.currentFrameIndex = 0,
    this.totalScore = 0,
    this.isComplete = false,
    required this.startedAt,
    this.completedAt,
  });

  BowlingGame copyWith({
    List<BowlingFrame>? frames,
    int? currentFrameIndex,
    int? totalScore,
    bool? isComplete,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return BowlingGame(
      frames: frames ?? this.frames,
      currentFrameIndex: currentFrameIndex ?? this.currentFrameIndex,
      totalScore: totalScore ?? this.totalScore,
      isComplete: isComplete ?? this.isComplete,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Get current frame being played
  BowlingFrame? get currentFrame {
    if (currentFrameIndex < frames.length) {
      return frames[currentFrameIndex];
    }
    return null;
  }

  // Check if we can add more rolls
  bool get canAddRoll {
    return !isComplete && currentFrame != null && !currentFrame!.isComplete;
  }

  // Calculate total score with strikes and spares
  int calculateTotalScore() {
    int total = 0;

    for (int i = 0; i < frames.length; i++) {
      final frame = frames[i];
      int frameScore = frame.frameScore;

      if (i < 9) {
        // Frames 1-9
        if (frame.isStrike) {
          // Strike: add next two rolls
          if (i + 1 < frames.length) {
            final nextFrame = frames[i + 1];
            if (nextFrame.rolls.isNotEmpty) {
              frameScore += nextFrame.rolls.first;
              if (nextFrame.rolls.length > 1) {
                frameScore += nextFrame.rolls[1];
              } else if (i + 2 < frames.length &&
                  frames[i + 2].rolls.isNotEmpty) {
                frameScore += frames[i + 2].rolls.first;
              }
            }
          }
        } else if (frame.isSpare) {
          // Spare: add next roll
          if (i + 1 < frames.length && frames[i + 1].rolls.isNotEmpty) {
            frameScore += frames[i + 1].rolls.first;
          }
        }
      }
      // 10th frame scoring is already included in frame.frameScore

      total += frameScore;
    }

    return total;
  }

  @override
  List<Object?> get props => [
    frames,
    currentFrameIndex,
    totalScore,
    isComplete,
    startedAt,
    completedAt,
  ];
}
