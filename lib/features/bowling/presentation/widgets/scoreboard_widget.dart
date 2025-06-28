import 'package:flutter/material.dart';
import '../../domain/entities/bowling_game.dart';
import '../../domain/entities/bowling_frame.dart';

class ScoreboardWidget extends StatelessWidget {
  final BowlingGame game;

  const ScoreboardWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade400, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SCORE BOARD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'TOTAL: ${game.calculateTotalScore()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Frame numbers
          Row(
            children: List.generate(10, (index) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    border: Border.all(color: Colors.green.shade400),
                  ),
                  child: Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),

          // Rolls row
          Row(
            children: List.generate(10, (index) {
              return Expanded(child: _buildFrameRolls(index));
            }),
          ),

          // Scores row
          Row(
            children: List.generate(10, (index) {
              return Expanded(child: _buildFrameScore(index));
            }),
          ),

          const SizedBox(height: 12),

          // Current frame indicator
          if (game.currentFrameIndex < 10)
            Row(
              children: [
                Icon(
                  Icons.arrow_forward,
                  color: Colors.green.shade400,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Frame: ${game.currentFrameIndex + 1}',
                  style: TextStyle(
                    color: Colors.green.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade400,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Game Complete!',
                  style: TextStyle(
                    color: Colors.green.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFrameRolls(int frameIndex) {
    if (frameIndex >= game.frames.length) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        height: 30,
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          border: Border.all(color: Colors.green.shade400),
        ),
        child: const Center(
          child: Text('-', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final frame = game.frames[frameIndex];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border.all(color: Colors.green.shade400),
      ),
      child: _buildRollsDisplay(frame),
    );
  }

  Widget _buildRollsDisplay(BowlingFrame frame) {
    if (frame.rolls.isEmpty) {
      return const Center(
        child: Text('-', style: TextStyle(color: Colors.white)),
      );
    }

    if (frame.frameNumber == 10) {
      // 10th frame special display
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: frame.rolls.map((roll) {
          return Text(
            _formatRoll(roll, frame),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList(),
      );
    } else {
      // Regular frames
      if (frame.isStrike) {
        return const Center(
          child: Text(
            'X',
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (frame.isSpare) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '${frame.rolls[0]}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '/',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: frame.rolls.map((roll) {
            return Text(
              roll == 0 ? '-' : '$roll',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        );
      }
    }
  }

  Widget _buildFrameScore(int frameIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      height: 25,
      decoration: BoxDecoration(
        color: Colors.grey.shade600,
        border: Border.all(color: Colors.green.shade400),
      ),
      child: Center(
        child: Text(
          frameIndex < game.frames.length
              ? '${_calculateRunningScore(frameIndex)}'
              : '-',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _formatRoll(int roll, BowlingFrame frame) {
    if (roll == 10) return 'X';
    if (roll == 0) return '-';
    return '$roll';
  }

  int _calculateRunningScore(int frameIndex) {
    int total = 0;
    for (int i = 0; i <= frameIndex && i < game.frames.length; i++) {
      total += game.frames[i].frameScore;
      // Add strike/spare bonuses for frames 1-9
      if (i < 9) {
        final frame = game.frames[i];
        if (frame.isStrike && i + 1 < game.frames.length) {
          final nextFrame = game.frames[i + 1];
          if (nextFrame.rolls.isNotEmpty) {
            total += nextFrame.rolls.first;
            if (nextFrame.rolls.length > 1) {
              total += nextFrame.rolls[1];
            } else if (i + 2 < game.frames.length &&
                game.frames[i + 2].rolls.isNotEmpty) {
              total += game.frames[i + 2].rolls.first;
            }
          }
        } else if (frame.isSpare && i + 1 < game.frames.length) {
          final nextFrame = game.frames[i + 1];
          if (nextFrame.rolls.isNotEmpty) {
            total += nextFrame.rolls.first;
          }
        }
      }
    }
    return total;
  }
}
