import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/app_router.dart';
import '../../../../core/services/game_manager.dart';
import '../../../profile/domain/entities/game_record.dart';
import '../../../../utils/sample_data_util.dart';

class BowlingDemoPage extends StatefulWidget {
  const BowlingDemoPage({super.key});

  @override
  State<BowlingDemoPage> createState() => _BowlingDemoPageState();
}

class _BowlingDemoPageState extends State<BowlingDemoPage> {
  Map<String, dynamic> todaysStats = {
    'totalGames': 0,
    'averageScore': 0,
    'bestScore': 0,
  };

  List<DailyGameSummary> recentGames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    try {
      final stats = await GameManager.getTodaysStats();
      final games = await GameManager.getGamesByDateGrouped();

      setState(() {
        todaysStats = stats;
        recentGames = games.take(5).toList(); // Show last 5 days
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error silently or show a snackbar
    }
  }

  void _showAddGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Game'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('When did you play this game?'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _navigateToGame(DateTime.now());
                      },
                      icon: const Icon(Icons.today),
                      label: const Text('Today'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showDatePicker(
                          this.context,
                        ); // Pass the State's context
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDatePicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      if (context.mounted) {
        _navigateToGame(selectedDate);
      }
    }
  }

  void _navigateToGame(DateTime gameDate) async {
    // Navigate to game and wait for result
    await context.push(
      '${AppRoutes.fullGame}?date=${gameDate.toIso8601String()}',
    );

    // Refresh data when returning from game
    _loadGameData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎳 Bowling Pin Score'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go(AppRoutes.profile),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(AppRoutes.settings),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.gamepad_outlined),
            onPressed: () => context.go(AppRoutes.fullGame),
            tooltip: 'Full Game Mode',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Game History Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'RECENT GAMES',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Recent Games List
                  if (recentGames.isEmpty && !isLoading)
                    Column(
                      children: [
                        Text(
                          'No games played yet. Start your first game!',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => context.go(AppRoutes.gameHistory),
                          icon: const Icon(Icons.history),
                          label: const Text('View All Games'),
                        ),
                      ],
                    )
                  else if (recentGames.isNotEmpty)
                    Column(
                      children: [
                        ...recentGames
                            .map(
                              (summary) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          summary.formattedDate,
                                          style: TextStyle(
                                            color: Colors.blue.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${summary.totalGames} game${summary.totalGames != 1 ? 's' : ''}',
                                          style: TextStyle(
                                            color: Colors.blue.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Avg: ${summary.averageScore.round()}',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => context.go(AppRoutes.gameHistory),
                          icon: const Icon(Icons.history),
                          label: const Text('View All Games'),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Loading recent games...',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Average',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${todaysStats['averageScore']}',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Games Today',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${todaysStats['totalGames']}',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Best Score',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${todaysStats['bestScore']}',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Features showcase
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ FEATURES',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    '🎯',
                    'Visual pin layout in standard 10-pin formation',
                  ),
                  _buildFeatureItem('✋', 'Tap to knock down/stand up pins'),
                  _buildFeatureItem('⚡', 'Quick Strike button for all pins'),
                  _buildFeatureItem('❌', 'Miss button for gutter balls'),
                  _buildFeatureItem(
                    '🎨',
                    'Smooth animations and visual feedback',
                  ),
                  _buildFeatureItem('🏆', 'No manual number input required'),
                  _buildFeatureItem('📊', 'Real-time score calculation'),
                  _buildFeatureItem('🎳', 'Professional bowling lane design'),
                  _buildFeatureItem(
                    '👤',
                    'Player profile with statistics & achievements',
                  ),
                  _buildFeatureItem('📈', 'Track your progress over time'),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Debug button to add sample data (only in debug mode)
          if (kDebugMode) ...[
            FloatingActionButton.small(
              heroTag: "addSampleData",
              onPressed: () async {
                await SampleDataUtil.addSampleGames();
                _loadGameData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sample games added!')),
                  );
                }
              },
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              child: const Icon(Icons.data_object),
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton.extended(
            heroTag: "addNewGame",
            onPressed: () => _showAddGameDialog(context),
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add New Game'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.green.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
