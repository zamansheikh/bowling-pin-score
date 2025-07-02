import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';
import 'profile_local_data_source.dart';

@Injectable(as: ProfileLocalDataSource)
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String _profileKey = 'user_profile';
  final SharedPreferences sharedPreferences;

  ProfileLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<UserProfileModel> getUserProfile() async {
    try {
      final profileString = sharedPreferences.getString(_profileKey);

      if (profileString != null) {
        final profileMap = jsonDecode(profileString) as Map<String, dynamic>;
        return UserProfileModel.fromJson(profileMap);
      } else {
        // Create default profile for new user
        final defaultProfile = _createDefaultProfile();
        await saveUserProfile(defaultProfile);
        return defaultProfile;
      }
    } catch (e) {
      throw CacheException('Failed to get user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserProfile(UserProfileModel profile) async {
    try {
      final profileString = jsonEncode(profile.toJson());
      await sharedPreferences.setString(_profileKey, profileString);
    } catch (e) {
      throw CacheException('Failed to save user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStatistics(UserStatisticsModel statistics) async {
    try {
      final currentProfile = await getUserProfile();
      final updatedProfile = UserProfileModel(
        id: currentProfile.id,
        name: currentProfile.name,
        avatarPath: currentProfile.avatarPath,
        createdAt: currentProfile.createdAt,
        lastActiveAt: DateTime.now(),
        statistics: statistics,
      );
      await saveUserProfile(updatedProfile);
    } catch (e) {
      throw CacheException('Failed to update statistics: ${e.toString()}');
    }
  }

  @override
  Future<void> saveGameResult({
    required int finalScore,
    required int strikes,
    required int spares,
    required int totalPins,
    required bool isPerfectGame,
  }) async {
    try {
      final currentProfile = await getUserProfile();
      final currentStats = currentProfile.statistics;

      // Update recent scores (keep last 10)
      final newRecentScores = [finalScore, ...currentStats.recentScores];
      if (newRecentScores.length > 10) {
        newRecentScores.removeRange(10, newRecentScores.length);
      }

      // Calculate new average
      final totalGames = currentStats.totalGamesPlayed + 1;
      final totalScore =
          (currentStats.averageScore * currentStats.totalGamesPlayed) +
          finalScore;
      final newAverage = totalScore / totalGames;

      // Update achievements
      final newAchievements = Map<String, int>.from(currentStats.achievements);
      _updateAchievements(
        newAchievements,
        finalScore,
        strikes,
        spares,
        isPerfectGame,
      );

      final updatedStats = UserStatisticsModel(
        totalGamesPlayed: totalGames,
        totalFramesPlayed:
            currentStats.totalFramesPlayed + 10, // Standard game has 10 frames
        totalPinsKnocked: currentStats.totalPinsKnocked + totalPins,
        highestGame: finalScore > currentStats.highestGame
            ? finalScore
            : currentStats.highestGame,
        averageScore: newAverage,
        totalStrikes: currentStats.totalStrikes + strikes,
        totalSpares: currentStats.totalSpares + spares,
        perfectGames: currentStats.perfectGames + (isPerfectGame ? 1 : 0),
        recentScores: newRecentScores,
        consecutiveStrikes: strikes > 0
            ? currentStats.consecutiveStrikes + strikes
            : 0,
        longestStrike: strikes > currentStats.longestStrike
            ? strikes
            : currentStats.longestStrike,
        achievements: newAchievements,
      );

      await updateStatistics(updatedStats);
    } catch (e) {
      throw CacheException('Failed to save game result: ${e.toString()}');
    }
  }

  UserProfileModel _createDefaultProfile() {
    return UserProfileModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Bowler',
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      statistics: UserStatisticsModel(),
    );
  }

  void _updateAchievements(
    Map<String, int> achievements,
    int score,
    int strikes,
    int spares,
    bool isPerfect,
  ) {
    // First game
    if (!achievements.containsKey('first_game')) {
      achievements['first_game'] = 1;
    }

    // Score milestones
    if (score >= 100 && !achievements.containsKey('century_club')) {
      achievements['century_club'] = 1;
    }
    if (score >= 150 && !achievements.containsKey('sesquicentennial')) {
      achievements['sesquicentennial'] = 1;
    }
    if (score >= 200 && !achievements.containsKey('double_century')) {
      achievements['double_century'] = 1;
    }

    // Perfect game
    if (isPerfect) {
      achievements['perfect_game'] = (achievements['perfect_game'] ?? 0) + 1;
    }

    // Strike achievements
    if (strikes >= 5) {
      achievements['strike_master'] = (achievements['strike_master'] ?? 0) + 1;
    }
    if (strikes >= 8) {
      achievements['strike_king'] = (achievements['strike_king'] ?? 0) + 1;
    }

    // Spare achievements
    if (spares >= 5) {
      achievements['spare_specialist'] =
          (achievements['spare_specialist'] ?? 0) + 1;
    }
  }
}
