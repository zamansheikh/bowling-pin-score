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
          onPressed: () => context.go(AppRoutes.home),
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

                  // Action buttons
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
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Complete Roll'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<BowlingBloc>().add(
                              BowlingFrameReset(),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset Frame'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // New Game button
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
