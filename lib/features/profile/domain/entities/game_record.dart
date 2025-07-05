import 'package:equatable/equatable.dart';

class GameRecord extends Equatable {
  final String id;
  final int score;
  final int strikes;
  final int spares;
  final int totalPins;
  final bool isPerfectGame;
  final DateTime playedAt;
  final List<int> frameScores; // Individual frame scores
  final Duration gameDuration;

  const GameRecord({
    required this.id,
    required this.score,
    required this.strikes,
    required this.spares,
    required this.totalPins,
    required this.isPerfectGame,
    required this.playedAt,
    required this.frameScores,
    required this.gameDuration,
  });

  GameRecord copyWith({
    String? id,
    int? score,
    int? strikes,
    int? spares,
    int? totalPins,
    bool? isPerfectGame,
    DateTime? playedAt,
    List<int>? frameScores,
    Duration? gameDuration,
  }) {
    return GameRecord(
      id: id ?? this.id,
      score: score ?? this.score,
      strikes: strikes ?? this.strikes,
      spares: spares ?? this.spares,
      totalPins: totalPins ?? this.totalPins,
      isPerfectGame: isPerfectGame ?? this.isPerfectGame,
      playedAt: playedAt ?? this.playedAt,
      frameScores: frameScores ?? this.frameScores,
      gameDuration: gameDuration ?? this.gameDuration,
    );
  }

  /// Get the date (without time) when the game was played
  DateTime get gameDate {
    return DateTime(playedAt.year, playedAt.month, playedAt.day);
  }

  /// Get a formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (gameDate == today) {
      return 'Today';
    } else if (gameDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${playedAt.day}/${playedAt.month}/${playedAt.year}';
    }
  }

  /// Get a formatted time string
  String get formattedTime {
    final hour = playedAt.hour;
    final minute = playedAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Get formatted game duration
  String get formattedDuration {
    final minutes = gameDuration.inMinutes;
    final seconds = gameDuration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  List<Object?> get props => [
    id,
    score,
    strikes,
    spares,
    totalPins,
    isPerfectGame,
    playedAt,
    frameScores,
    gameDuration,
  ];
}

class DailyGameSummary extends Equatable {
  final DateTime date;
  final List<GameRecord> games;

  const DailyGameSummary({required this.date, required this.games});

  /// Get total number of games played on this date
  int get totalGames => games.length;

  /// Get average score for the day
  double get averageScore {
    if (games.isEmpty) return 0.0;
    final totalScore = games.fold(0, (sum, game) => sum + game.score);
    return totalScore / games.length;
  }

  /// Get highest score for the day
  int get highestScore {
    if (games.isEmpty) return 0;
    return games.map((game) => game.score).reduce((a, b) => a > b ? a : b);
  }

  /// Get lowest score for the day
  int get lowestScore {
    if (games.isEmpty) return 0;
    return games.map((game) => game.score).reduce((a, b) => a < b ? a : b);
  }

  /// Get total strikes for the day
  int get totalStrikes {
    return games.fold(0, (sum, game) => sum + game.strikes);
  }

  /// Get total spares for the day
  int get totalSpares {
    return games.fold(0, (sum, game) => sum + game.spares);
  }

  /// Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  List<Object?> get props => [date, games];
}
