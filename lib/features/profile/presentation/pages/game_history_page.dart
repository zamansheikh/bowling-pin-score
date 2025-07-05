import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/game_record.dart';
import '../../domain/usecases/get_game_records.dart';

class GameHistoryPage extends StatefulWidget {
  const GameHistoryPage({super.key});

  @override
  State<GameHistoryPage> createState() => _GameHistoryPageState();
}

class _GameHistoryPageState extends State<GameHistoryPage> {
  final GetGameRecords _getGameRecords = getIt<GetGameRecords>();
  List<DailyGameSummary> _dailySummaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameHistory();
  }

  Future<void> _loadGameHistory() async {
    setState(() => _isLoading = true);

    final result = await _getGameRecords.getDailySummaries();
    result.fold(
      (failure) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load game history: ${failure.message}'),
          ),
        );
      },
      (summaries) {
        setState(() {
          _dailySummaries = summaries;
        });
      },
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Game History'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGameHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dailySummaries.isEmpty
          ? _buildEmptyState()
          : _buildGameHistory(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Games Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start playing to see your game history here!',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameHistory() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dailySummaries.length,
      itemBuilder: (context, index) {
        final summary = _dailySummaries[index];
        return _buildDaySummaryCard(summary);
      },
    );
  }

  Widget _buildDaySummaryCard(DailyGameSummary summary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(Icons.calendar_today, color: Colors.purple.shade600),
        title: Text(
          summary.formattedDate,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${summary.totalGames} games • Avg: ${summary.averageScore.toStringAsFixed(1)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Summary stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Games',
                        '${summary.totalGames}',
                        Icons.sports_score,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Average',
                        summary.averageScore.toStringAsFixed(1),
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Best',
                        '${summary.highestScore}',
                        Icons.star,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Strikes',
                        '${summary.totalStrikes}',
                        Icons.bolt,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Individual games
                ...summary.games.map((game) => _buildGameCard(game)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(GameRecord game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Score
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: game.isPerfectGame
                  ? Colors.amber.shade600
                  : game.score >= 200
                  ? Colors.purple.shade600
                  : game.score >= 150
                  ? Colors.blue.shade600
                  : Colors.green.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${game.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Game details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      game.formattedTime,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (game.isPerfectGame) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'PERFECT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildGameStat('⚡', '${game.strikes}'),
                    const SizedBox(width: 12),
                    _buildGameStat('🎯', '${game.spares}'),
                    const SizedBox(width: 12),
                    _buildGameStat('⏱️', game.formattedDuration),
                  ],
                ),
              ],
            ),
          ),
          // Action button
          IconButton(
            onPressed: () => _showGameDetails(game),
            icon: const Icon(Icons.info_outline),
            tooltip: 'View Details',
          ),
        ],
      ),
    );
  }

  Widget _buildGameStat(String icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showGameDetails(GameRecord game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('Game Details'),
            if (game.isPerfectGame) ...[
              const SizedBox(width: 8),
              Icon(Icons.star, color: Colors.amber.shade600),
            ],
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${game.score}'),
            Text('Played: ${game.formattedDate} at ${game.formattedTime}'),
            Text('Duration: ${game.formattedDuration}'),
            Text('Strikes: ${game.strikes}'),
            Text('Spares: ${game.spares}'),
            Text('Total Pins: ${game.totalPins}'),
            const SizedBox(height: 8),
            Text(
              'Frame Scores:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(game.frameScores.join(', ')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
