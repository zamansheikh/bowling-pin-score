import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection/injection.dart';
import '../../../../routing/app_router.dart';
import '../../../../core/services/game_manager.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/user_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (context) => getIt<ProfileBloc>()..add(ProfileLoadRequested()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<String, dynamic> gameStats = {
    'totalGames': 0,
    'averageScore': 0.0,
    'bestScore': 0,
    'perfectGames': 0,
    'totalStrikes': 0,
    'totalSpares': 0,
  };
  bool statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameStats();
  }

  Future<void> _loadGameStats() async {
    try {
      final stats = await GameManager.getOverallStats();
      setState(() {
        gameStats = stats;
        statsLoading = false;
      });
    } catch (e) {
      setState(() {
        statsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
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
                      context.read<ProfileBloc>().add(ProfileLoadRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            return _buildProfileContent(context, state.profile);
          }

          return const Center(child: Text('Welcome to your Profile!'));
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    return CustomScrollView(
      slivers: [
        // App Bar with gradient
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.indigo.shade700,
                    Colors.purple.shade600,
                    Colors.pink.shade500,
                  ],
                ),
              ),
            ),
            title: const Text(
              '👤 Player Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Colors.indigo.shade700,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go(AppRoutes.home),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () => context.push(AppRoutes.gameHistory),
              tooltip: 'Game History',
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => _showEditProfileDialog(context, profile),
              tooltip: 'Edit Profile',
            ),
          ],
        ),

        // Profile Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(profile),
                const SizedBox(height: 24),

                // Statistics Grid
                _buildStatisticsGrid(),
                const SizedBox(height: 24),

                // Recent Scores
                _buildRecentScores(profile.statistics),
                const SizedBox(height: 24),

                // Achievements
                _buildAchievements(profile.statistics),
                const SizedBox(height: 24),

                // Performance Chart
                _buildPerformanceSection(profile.statistics),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade600,
              Colors.purple.shade700,
              Colors.indigo.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              profile.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Skill Level Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _getSkillLevelColor(profile.statistics.skillLevel),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profile.statistics.skillLevel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Join Date
            Text(
              'Joined ${_formatDate(profile.createdAt)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (statsLoading)
              const Center(child: CircularProgressIndicator())
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(
                    'Games Played',
                    '${gameStats['totalGames']}',
                    Icons.sports_score,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'High Score',
                    '${gameStats['bestScore']}',
                    Icons.star,
                    Colors.amber,
                  ),
                  _buildStatCard(
                    'Average Score',
                    '${gameStats['averageScore']}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Total Strikes',
                    '${gameStats['totalStrikes']}',
                    Icons.bolt,
                    Colors.red,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScores(UserStatistics stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                Text(
                  'Recent Games',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats.recentScores.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.sports, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No recent scores yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Play some games to see your progress!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stats.recentScores.length,
                  itemBuilder: (context, index) {
                    final score = stats.recentScores[index];
                    final isHighScore = score == stats.highestGame;
                    return Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isHighScore
                            ? Colors.amber.shade600
                            : _getScoreColor(score),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isHighScore
                                        ? Colors.amber.shade600
                                        : _getScoreColor(score))
                                    .withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isHighScore) ...[
                            Icon(Icons.star, color: Colors.white, size: 16),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            '$score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Game ${index + 1}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(UserStatistics stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats.achievements.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No achievements yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep playing to unlock achievements!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: stats.achievements.entries.map((entry) {
                  return _buildAchievementBadge(entry.key, entry.value);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(String achievement, int count) {
    final info = _getAchievementInfo(achievement);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(info['icon']!, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            info['name']!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade800,
              fontSize: 12,
            ),
          ),
          if (count > 1) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(UserStatistics stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                Text(
                  'Performance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceCard(
                    'Strike Rate',
                    '${stats.strikePercentage.toStringAsFixed(1)}%',
                    Icons.bolt,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPerformanceCard(
                    'Spare Rate',
                    '${stats.sparePercentage.toStringAsFixed(1)}%',
                    Icons.check_circle,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceCard(
                    'Best Streak',
                    '${stats.longestStrike}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPerformanceCard(
                    'Total Pins',
                    '${stats.totalPinsKnocked}',
                    Icons.sports_score,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProfileBloc>().add(
                ProfileUpdateRequested(name: nameController.text.trim()),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _getSkillLevelColor(String skillLevel) {
    switch (skillLevel) {
      case 'Professional':
        return Colors.amber.shade600;
      case 'Advanced':
        return Colors.purple.shade600;
      case 'Intermediate':
        return Colors.blue.shade600;
      case 'Beginner+':
        return Colors.green.shade600;
      case 'Beginner':
        return Colors.orange.shade600;
      default:
        return Colors.red.shade600;
    }
  }

  Color _getScoreColor(int score) {
    if (score == 300) return Colors.amber; // Perfect game
    if (score >= 200) return Colors.purple;
    if (score >= 150) return Colors.blue;
    if (score >= 100) return Colors.green;
    return Colors.orange;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    if (difference < 365) return '${(difference / 30).floor()} months ago';
    return '${(difference / 365).floor()} years ago';
  }

  Map<String, String> _getAchievementInfo(String achievement) {
    const achievements = {
      'first_game': {'icon': '🎯', 'name': 'First Game'},
      'century_club': {'icon': '💯', 'name': 'Century Club'},
      'sesquicentennial': {'icon': '🔥', 'name': 'Hot Streak'},
      'double_century': {'icon': '🚀', 'name': 'High Roller'},
      'perfect_game': {'icon': '⭐', 'name': 'Perfect Game'},
      'strike_master': {'icon': '⚡', 'name': 'Strike Master'},
      'strike_king': {'icon': '👑', 'name': 'Strike King'},
      'spare_specialist': {'icon': '🎪', 'name': 'Spare Specialist'},
    };

    return achievements[achievement] ?? {'icon': '🏆', 'name': 'Achievement'};
  }
}
