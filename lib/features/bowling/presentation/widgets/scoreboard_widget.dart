import 'package:flutter/material.dart';
import '../../domain/entities/bowling_game.dart';
import '../../domain/entities/bowling_frame.dart';

class ScoreboardWidget extends StatelessWidget {
  final BowlingGame game;

  const ScoreboardWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Total Score - Big and prominent
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'TOTAL SCORE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${game.calculateTotalScore()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    game.currentFrameIndex >= 10
                        ? Icons.check_circle
                        : Icons.sports_score,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    game.currentFrameIndex >= 10
                        ? 'Game Complete!'
                        : 'Frame ${game.currentFrameIndex + 1} of 10',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Frame Summary - Mobile optimized
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.view_module,
                    color: Colors.grey.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FRAME SCORES',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Frame grid - 2 rows of 5 frames for better mobile layout
              _buildMobileFrameGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFrameGrid() {
    return Column(
      children: [
        // First row: Frames 1-5
        Row(
          children: List.generate(
            5,
            (index) => Expanded(child: _buildMobileFrame(index)),
          ),
        ),
        const SizedBox(height: 8),
        // Second row: Frames 6-10
        Row(
          children: List.generate(
            5,
            (index) => Expanded(child: _buildMobileFrame(index + 5)),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFrame(int frameIndex) {
    final isCurrentFrame = frameIndex == game.currentFrameIndex;
    final hasFrame = frameIndex < game.frames.length;
    final frame = hasFrame ? game.frames[frameIndex] : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          // Frame number
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: isCurrentFrame
                  ? Colors.green.shade600
                  : Colors.grey.shade600,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
            child: Center(
              child: Text(
                '${frameIndex + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Rolls display
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: hasFrame ? Colors.blue.shade50 : Colors.grey.shade200,
              border: Border.all(
                color: isCurrentFrame
                    ? Colors.green.shade600
                    : Colors.grey.shade400,
                width: isCurrentFrame ? 2 : 1,
              ),
            ),
            child: Center(
              child: hasFrame
                  ? _buildMobileRollsDisplay(frame!)
                  : const Text('-', style: TextStyle(color: Colors.grey)),
            ),
          ),

          // Score
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: hasFrame && frame!.rolls.isNotEmpty
                  ? Colors.green.shade100
                  : Colors.grey.shade300,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(6),
              ),
              border: Border.all(
                color: isCurrentFrame
                    ? Colors.green.shade600
                    : Colors.grey.shade400,
                width: isCurrentFrame ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                hasFrame && frame!.rolls.isNotEmpty
                    ? '${_calculateRunningScore(frameIndex)}'
                    : '-',
                style: TextStyle(
                  color: hasFrame && frame!.rolls.isNotEmpty
                      ? Colors.green.shade800
                      : Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileRollsDisplay(BowlingFrame frame) {
    if (frame.rolls.isEmpty) {
      return const Text('-', style: TextStyle(color: Colors.grey));
    }

    if (frame.isStrike) {
      return Text(
        'X',
        style: TextStyle(
          color: Colors.red.shade600,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (frame.isSpare) {
      return Text(
        '${frame.rolls[0]}/',
        style: TextStyle(
          color: Colors.orange.shade600,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return Text(
        frame.rolls.map((r) => r == 0 ? '-' : '$r').join(' '),
        style: TextStyle(
          color: Colors.blue.shade700,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  int _calculateRunningScore(int frameIndex) {
    // Calculate running total up to this frame
    int total = 0;

    for (int i = 0; i <= frameIndex && i < game.frames.length; i++) {
      final frame = game.frames[i];
      int frameScore = frame.frameScore;

      if (i < 9) {
        // Frames 1-9: Add strike/spare bonuses
        if (frame.isStrike) {
          // Strike: add next two rolls
          if (i + 1 < game.frames.length) {
            final nextFrame = game.frames[i + 1];
            if (nextFrame.rolls.isNotEmpty) {
              frameScore += nextFrame.rolls.first;
              if (nextFrame.rolls.length > 1) {
                frameScore += nextFrame.rolls[1];
              } else if (i + 2 < game.frames.length &&
                  game.frames[i + 2].rolls.isNotEmpty) {
                frameScore += game.frames[i + 2].rolls.first;
              }
            }
          }
        } else if (frame.isSpare) {
          // Spare: add next roll
          if (i + 1 < game.frames.length &&
              game.frames[i + 1].rolls.isNotEmpty) {
            frameScore += game.frames[i + 1].rolls.first;
          }
        }
      }
      // 10th frame scoring is already included in frame.frameScore

      total += frameScore;
    }

    return total;
  }
}
