import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final UserStatistics statistics;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatarPath,
    required this.createdAt,
    required this.lastActiveAt,
    required this.statistics,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    UserStatistics? statistics,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      statistics: statistics ?? this.statistics,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarPath,
    createdAt,
    lastActiveAt,
    statistics,
  ];
}

class UserStatistics extends Equatable {
  final int totalGamesPlayed;
  final int totalFramesPlayed;
  final int totalPinsKnocked;
  final int highestGame;
  final double averageScore;
  final int totalStrikes;
  final int totalSpares;
  final int perfectGames; // Score of 300
  final List<int> recentScores; // Last 10 games
  final int consecutiveStrikes; // Current streak
  final int longestStrike; // Best strike streak
  final Map<String, int> achievements; // Achievement name -> count

  const UserStatistics({
    this.totalGamesPlayed = 0,
    this.totalFramesPlayed = 0,
    this.totalPinsKnocked = 0,
    this.highestGame = 0,
    this.averageScore = 0.0,
    this.totalStrikes = 0,
    this.totalSpares = 0,
    this.perfectGames = 0,
    this.recentScores = const [],
    this.consecutiveStrikes = 0,
    this.longestStrike = 0,
    this.achievements = const {},
  });

  UserStatistics copyWith({
    int? totalGamesPlayed,
    int? totalFramesPlayed,
    int? totalPinsKnocked,
    int? highestGame,
    double? averageScore,
    int? totalStrikes,
    int? totalSpares,
    int? perfectGames,
    List<int>? recentScores,
    int? consecutiveStrikes,
    int? longestStrike,
    Map<String, int>? achievements,
  }) {
    return UserStatistics(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalFramesPlayed: totalFramesPlayed ?? this.totalFramesPlayed,
      totalPinsKnocked: totalPinsKnocked ?? this.totalPinsKnocked,
      highestGame: highestGame ?? this.highestGame,
      averageScore: averageScore ?? this.averageScore,
      totalStrikes: totalStrikes ?? this.totalStrikes,
      totalSpares: totalSpares ?? this.totalSpares,
      perfectGames: perfectGames ?? this.perfectGames,
      recentScores: recentScores ?? this.recentScores,
      consecutiveStrikes: consecutiveStrikes ?? this.consecutiveStrikes,
      longestStrike: longestStrike ?? this.longestStrike,
      achievements: achievements ?? this.achievements,
    );
  }

  /// Calculate strike percentage
  double get strikePercentage {
    if (totalFramesPlayed == 0) return 0.0;
    return (totalStrikes / totalFramesPlayed) * 100;
  }

  /// Calculate spare percentage
  double get sparePercentage {
    if (totalFramesPlayed == 0) return 0.0;
    return (totalSpares / totalFramesPlayed) * 100;
  }

  /// Get player skill level based on average score
  String get skillLevel {
    if (averageScore >= 200) return 'Professional';
    if (averageScore >= 180) return 'Advanced';
    if (averageScore >= 150) return 'Intermediate';
    if (averageScore >= 120) return 'Beginner+';
    if (averageScore >= 90) return 'Beginner';
    return 'Novice';
  }

  /// Get skill level color
  String get skillLevelColor {
    switch (skillLevel) {
      case 'Professional':
        return 'gold';
      case 'Advanced':
        return 'purple';
      case 'Intermediate':
        return 'blue';
      case 'Beginner+':
        return 'green';
      case 'Beginner':
        return 'orange';
      default:
        return 'red';
    }
  }

  @override
  List<Object?> get props => [
    totalGamesPlayed,
    totalFramesPlayed,
    totalPinsKnocked,
    highestGame,
    averageScore,
    totalStrikes,
    totalSpares,
    perfectGames,
    recentScores,
    consecutiveStrikes,
    longestStrike,
    achievements,
  ];
}
