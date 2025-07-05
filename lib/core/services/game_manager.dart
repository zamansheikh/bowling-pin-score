import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../features/profile/domain/entities/game_record.dart';

/// GameManager class to handle game data with SharedPreferences
class GameManager {
  static const String _datesKey = 'game_dates';

  /// Format date to YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Save a game record for a specific date
  static Future<void> saveGame(GameRecord game) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = 'games_${_formatDate(game.playedAt)}';

    try {
      // Get existing games for the date
      List<GameRecord> games = await getGamesByDate(game.playedAt);
      games.add(game);

      // Save updated games list
      final gamesJson = games.map((g) => _gameToJson(g)).toList();
      await prefs.setString(dateKey, jsonEncode(gamesJson));

      // Update the list of dates
      List<String> dates = prefs.getStringList(_datesKey) ?? [];
      if (!dates.contains(dateKey)) {
        dates.add(dateKey);
        dates.sort(); // Keep dates sorted
        await prefs.setStringList(_datesKey, dates);
      }
    } catch (e) {
      throw Exception('Failed to save game: $e');
    }
  }

  /// Retrieve games for a specific date
  static Future<List<GameRecord>> getGamesByDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = 'games_${_formatDate(date)}';

    try {
      final gamesJson = prefs.getString(dateKey);
      if (gamesJson == null) return [];

      final List<dynamic> gamesList = jsonDecode(gamesJson);
      return gamesList.map((json) => _gameFromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to retrieve games for date: $e');
    }
  }

  /// Retrieve games for a date range
  static Future<List<GameRecord>> getGamesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final dates = prefs.getStringList(_datesKey) ?? [];
    List<GameRecord> allGames = [];

    try {
      for (String dateKey in dates) {
        final date = DateTime.parse(dateKey.replaceFirst('games_', ''));
        if (date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            date.isBefore(endDate.add(const Duration(days: 1)))) {
          final games = await getGamesByDate(date);
          allGames.addAll(games);
        }
      }

      // Sort games by date (newest first)
      allGames.sort((a, b) => b.playedAt.compareTo(a.playedAt));
      return allGames;
    } catch (e) {
      throw Exception('Failed to retrieve games for date range: $e');
    }
  }

  /// Retrieve all games
  static Future<List<GameRecord>> getAllGames() async {
    final prefs = await SharedPreferences.getInstance();
    final dates = prefs.getStringList(_datesKey) ?? [];
    List<GameRecord> allGames = [];

    try {
      for (String dateKey in dates) {
        final games = await getGamesByDate(
          DateTime.parse(dateKey.replaceFirst('games_', '')),
        );
        allGames.addAll(games);
      }

      // Sort games by date (newest first)
      allGames.sort((a, b) => b.playedAt.compareTo(a.playedAt));
      return allGames;
    } catch (e) {
      throw Exception('Failed to retrieve all games: $e');
    }
  }

  /// Get today's games
  static Future<List<GameRecord>> getTodaysGames() async {
    final today = DateTime.now();
    return await getGamesByDate(today);
  }

  /// Get games grouped by date
  static Future<List<DailyGameSummary>> getGamesByDateGrouped() async {
    final prefs = await SharedPreferences.getInstance();
    final dates = prefs.getStringList(_datesKey) ?? [];
    List<DailyGameSummary> dailySummaries = [];

    try {
      for (String dateKey in dates) {
        final date = DateTime.parse(dateKey.replaceFirst('games_', ''));
        final games = await getGamesByDate(date);
        if (games.isNotEmpty) {
          dailySummaries.add(DailyGameSummary(date: date, games: games));
        }
      }

      // Sort by date (newest first)
      dailySummaries.sort((a, b) => b.date.compareTo(a.date));
      return dailySummaries;
    } catch (e) {
      throw Exception('Failed to retrieve grouped games: $e');
    }
  }

  /// Get statistics for today
  static Future<Map<String, dynamic>> getTodaysStats() async {
    final todaysGames = await getTodaysGames();

    if (todaysGames.isEmpty) {
      return {
        'totalGames': 0,
        'averageScore': 0.0,
        'bestScore': 0,
        'totalStrikes': 0,
        'totalSpares': 0,
      };
    }

    final totalScore = todaysGames.fold(0, (sum, game) => sum + game.score);
    final averageScore = totalScore / todaysGames.length;
    final bestScore = todaysGames
        .map((game) => game.score)
        .reduce((a, b) => a > b ? a : b);
    final totalStrikes = todaysGames.fold(0, (sum, game) => sum + game.strikes);
    final totalSpares = todaysGames.fold(0, (sum, game) => sum + game.spares);

    return {
      'totalGames': todaysGames.length,
      'averageScore': averageScore.round(),
      'bestScore': bestScore,
      'totalStrikes': totalStrikes,
      'totalSpares': totalSpares,
    };
  }

  /// Get overall statistics
  static Future<Map<String, dynamic>> getOverallStats() async {
    final allGames = await getAllGames();

    if (allGames.isEmpty) {
      return {
        'totalGames': 0,
        'averageScore': 0.0,
        'bestScore': 0,
        'perfectGames': 0,
        'totalStrikes': 0,
        'totalSpares': 0,
      };
    }

    final totalScore = allGames.fold(0, (sum, game) => sum + game.score);
    final averageScore = totalScore / allGames.length;
    final bestScore = allGames
        .map((game) => game.score)
        .reduce((a, b) => a > b ? a : b);
    final perfectGames = allGames.where((game) => game.isPerfectGame).length;
    final totalStrikes = allGames.fold(0, (sum, game) => sum + game.strikes);
    final totalSpares = allGames.fold(0, (sum, game) => sum + game.spares);

    return {
      'totalGames': allGames.length,
      'averageScore': averageScore.round(),
      'bestScore': bestScore,
      'perfectGames': perfectGames,
      'totalStrikes': totalStrikes,
      'totalSpares': totalSpares,
    };
  }

  /// Delete a specific game
  static Future<void> deleteGame(String gameId, DateTime gameDate) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = 'games_${_formatDate(gameDate)}';

    try {
      List<GameRecord> games = await getGamesByDate(gameDate);
      games.removeWhere((game) => game.id == gameId);

      if (games.isEmpty) {
        // Remove the date key if no games left
        await prefs.remove(dateKey);

        // Update the list of dates
        List<String> dates = prefs.getStringList(_datesKey) ?? [];
        dates.remove(dateKey);
        await prefs.setStringList(_datesKey, dates);
      } else {
        // Save updated games list
        final gamesJson = games.map((g) => _gameToJson(g)).toList();
        await prefs.setString(dateKey, jsonEncode(gamesJson));
      }
    } catch (e) {
      throw Exception('Failed to delete game: $e');
    }
  }

  /// Clear all game data (use with caution)
  static Future<void> clearAllGames() async {
    final prefs = await SharedPreferences.getInstance();
    final dates = prefs.getStringList(_datesKey) ?? [];

    try {
      // Remove all game data
      for (String dateKey in dates) {
        await prefs.remove(dateKey);
      }

      // Clear the dates list
      await prefs.remove(_datesKey);
    } catch (e) {
      throw Exception('Failed to clear all games: $e');
    }
  }

  /// Convert GameRecord to JSON Map
  static Map<String, dynamic> _gameToJson(GameRecord game) {
    return {
      'id': game.id,
      'score': game.score,
      'strikes': game.strikes,
      'spares': game.spares,
      'totalPins': game.totalPins,
      'isPerfectGame': game.isPerfectGame,
      'playedAt': game.playedAt.toIso8601String(),
      'frameScores': game.frameScores,
      'gameDurationInSeconds': game.gameDuration.inSeconds,
    };
  }

  /// Convert JSON Map to GameRecord
  static GameRecord _gameFromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'] as String,
      score: json['score'] as int,
      strikes: json['strikes'] as int,
      spares: json['spares'] as int,
      totalPins: json['totalPins'] as int,
      isPerfectGame: json['isPerfectGame'] as bool,
      playedAt: DateTime.parse(json['playedAt'] as String),
      frameScores: List<int>.from(json['frameScores'] as List),
      gameDuration: Duration(seconds: json['gameDurationInSeconds'] as int),
    );
  }
}
