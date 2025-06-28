import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/app_router.dart';
import '../bloc/bowling_bloc.dart';
import '../widgets/bowling_lane_widget.dart';
import '../widgets/scoreboard_widget.dart';

class BowlingPage extends StatelessWidget {
  const BowlingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Start the bowling game when page loads
    context.read<BowlingBloc>().add(BowlingGameStarted());
    return const BowlingView();
  }
}

class BowlingView extends StatelessWidget {
  const BowlingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎳 Pin Score Tracker'),
        centerTitle: true,
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.demo),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: BlocBuilder<BowlingBloc, BowlingState>(
        builder: (context, state) {
          if (state is BowlingLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading bowling game...'),
                ],
              ),
            );
          }

          if (state is BowlingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BowlingBloc>().add(BowlingGameStarted());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is BowlingGameLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Scoreboard
                  ScoreboardWidget(game: state.game),

                  const SizedBox(height: 24),

                  // Current status
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        if (state.message != null)
                          Text(
                            state.message!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Pins knocked down: ${state.currentPins.where((pin) => pin.isKnockedDown).length}/10',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bowling Lane
                  BowlingLaneWidget(
                    pins: state.currentPins,
                    onPinTapped: (pinPosition) {
                      if (state.canRoll) {
                        context.read<BowlingBloc>().add(
                          BowlingPinTapped(pinPosition),
                        );
                      }
                    },
                    isInteractive: state.canRoll,
                  ),

                  const SizedBox(height: 24),

                  // Action buttons - Mobile-optimized for Android
                  Column(
                    children: [
                      // Quick action buttons (Strike & Miss)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: state.canRoll
                                  ? () {
                                      // Set all pins to standing (Miss/Gutter ball)
                                      context.read<BowlingBloc>().add(
                                        BowlingAllPinsReset(),
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text(
                                'Miss',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: state.canRoll
                                  ? () {
                                      // Set all pins to knocked down (Strike)
                                      context.read<BowlingBloc>().add(
                                        BowlingAllPinsKnocked(),
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.bolt, size: 18),
                              label: const Text(
                                'Strike!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Game control buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: state.canRoll
                                  ? () {
                                      context.read<BowlingBloc>().add(
                                        BowlingRollCompleted(),
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text(
                                'Complete Roll',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<BowlingBloc>().add(
                                  BowlingFrameReset(),
                                );
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text(
                                'Reset Frame',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // How to Play Guide - Mobile friendly
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.help_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'HOW TO PLAY',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildGuideStep(
                          '1',
                          'Tap pins to knock them down, or use Strike/Miss buttons',
                        ),
                        _buildGuideStep(
                          '2',
                          'Tap "Complete Roll" to finish your current roll',
                        ),
                        _buildGuideStep(
                          '3',
                          'You get 2 rolls per frame (except strikes)',
                        ),
                        _buildGuideStep(
                          '4',
                          'Strike = All pins in 1 roll (10 points + bonus)',
                        ),
                        _buildGuideStep(
                          '5',
                          'Spare = All pins in 2 rolls (10 points + bonus)',
                        ),
                        _buildGuideStep(
                          '6',
                          'Game has 10 frames, 10th frame has special rules',
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.yellow.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.orange.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tip: Watch the current frame indicator in the scoreboard!',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // New Game button
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showNewGameDialog(context);
                      },
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Start New Game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Welcome to Bowling Pin Score Tracker!'),
          );
        },
      ),
    );
  }

  Widget _buildGuideStep(String number, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Start New Game'),
        content: const Text(
          'Are you sure you want to start a new game? This will reset your current progress.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<BowlingBloc>().add(BowlingNewGameStarted());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start New Game'),
          ),
        ],
      ),
    );
  }
}
