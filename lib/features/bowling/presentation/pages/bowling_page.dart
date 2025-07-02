import 'package:bowlingpinscore/features/bowling/presentation/widgets/frame_scrore_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/app_router.dart';
import '../../../../injection/injection.dart';
import '../bloc/bowling_bloc.dart';
import '../widgets/bowling_lane_widget.dart';

class BowlingPage extends StatelessWidget {
  const BowlingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BowlingBloc>(
      create: (context) => getIt<BowlingBloc>(),
      child: const BowlingView(),
    );
  }
}

class BowlingView extends StatefulWidget {
  const BowlingView({super.key});

  @override
  State<BowlingView> createState() => _BowlingViewState();
}

class _BowlingViewState extends State<BowlingView> {
  @override
  void initState() {
    super.initState();
    // Initialize the game when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BowlingBloc>().add(BowlingGameStarted());
    });
  }

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
          // Debug reset button (for testing)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force start new game
              context.read<BowlingBloc>().add(BowlingNewGameStarted());
            },
            tooltip: 'Force Reset Game',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go(AppRoutes.profile),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          BlocBuilder<BowlingBloc, BowlingState>(
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
                          context.read<BowlingBloc>().add(
                            BowlingNewGameStarted(),
                          );
                        },
                        child: const Text('Start New Game'),
                      ),
                    ],
                  ),
                );
              }

              if (state is BowlingGameLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 140, // Extra padding for floating buttons
                  ),
                  child: Column(
                    children: [
                      // Scoreboard
                      FrameScoreGrid(game: state.game),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 16),
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

          // Floating Action Buttons Overlay
          BlocBuilder<BowlingBloc, BowlingState>(
            builder: (context, state) {
              if (state is! BowlingGameLoaded) return const SizedBox.shrink();

              return Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Miss button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: state.canRoll
                              ? () {
                                  context.read<BowlingBloc>().add(
                                    BowlingAllPinsReset(),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cancel_outlined, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                'Miss',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Strike button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: state.canRoll
                              ? () {
                                  context.read<BowlingBloc>().add(
                                    BowlingAllPinsKnocked(),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                'Strike',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Complete button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: state.canRoll
                              ? () {
                                  context.read<BowlingBloc>().add(
                                    BowlingRollCompleted(),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Reset button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<BowlingBloc>().add(
                              BowlingFrameReset(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.refresh, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
