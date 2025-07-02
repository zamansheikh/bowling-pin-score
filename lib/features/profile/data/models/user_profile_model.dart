import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final UserStatisticsModel statistics;

  UserProfileModel({
    required this.id,
    required this.name,
    this.avatarPath,
    required this.createdAt,
    required this.lastActiveAt,
    required this.statistics,
  });

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      avatarPath: entity.avatarPath,
      createdAt: entity.createdAt,
      lastActiveAt: entity.lastActiveAt,
      statistics: UserStatisticsModel.fromEntity(entity.statistics),
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      avatarPath: avatarPath,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt,
      statistics: statistics.toEntity(),
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Player',
      avatarPath: json['avatarPath'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastActiveAt: DateTime.parse(
        json['lastActiveAt'] ?? DateTime.now().toIso8601String(),
      ),
      statistics: UserStatisticsModel.fromJson(json['statistics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarPath': avatarPath,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'statistics': statistics.toJson(),
    };
  }
}

class UserStatisticsModel {
  final int totalGamesPlayed;
  final int totalFramesPlayed;
  final int totalPinsKnocked;
  final int highestGame;
  final double averageScore;
  final int totalStrikes;
  final int totalSpares;
  final int perfectGames;
  final List<int> recentScores;
  final int consecutiveStrikes;
  final int longestStrike;
  final Map<String, int> achievements;

  UserStatisticsModel({
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

  factory UserStatisticsModel.fromEntity(UserStatistics entity) {
    return UserStatisticsModel(
      totalGamesPlayed: entity.totalGamesPlayed,
      totalFramesPlayed: entity.totalFramesPlayed,
      totalPinsKnocked: entity.totalPinsKnocked,
      highestGame: entity.highestGame,
      averageScore: entity.averageScore,
      totalStrikes: entity.totalStrikes,
      totalSpares: entity.totalSpares,
      perfectGames: entity.perfectGames,
      recentScores: entity.recentScores,
      consecutiveStrikes: entity.consecutiveStrikes,
      longestStrike: entity.longestStrike,
      achievements: entity.achievements,
    );
  }

  UserStatistics toEntity() {
    return UserStatistics(
      totalGamesPlayed: totalGamesPlayed,
      totalFramesPlayed: totalFramesPlayed,
      totalPinsKnocked: totalPinsKnocked,
      highestGame: highestGame,
      averageScore: averageScore,
      totalStrikes: totalStrikes,
      totalSpares: totalSpares,
      perfectGames: perfectGames,
      recentScores: recentScores,
      consecutiveStrikes: consecutiveStrikes,
      longestStrike: longestStrike,
      achievements: achievements,
    );
  }

  factory UserStatisticsModel.fromJson(Map<String, dynamic> json) {
    return UserStatisticsModel(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalFramesPlayed: json['totalFramesPlayed'] ?? 0,
      totalPinsKnocked: json['totalPinsKnocked'] ?? 0,
      highestGame: json['highestGame'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      totalStrikes: json['totalStrikes'] ?? 0,
      totalSpares: json['totalSpares'] ?? 0,
      perfectGames: json['perfectGames'] ?? 0,
      recentScores: List<int>.from(json['recentScores'] ?? []),
      consecutiveStrikes: json['consecutiveStrikes'] ?? 0,
      longestStrike: json['longestStrike'] ?? 0,
      achievements: Map<String, int>.from(json['achievements'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalFramesPlayed': totalFramesPlayed,
      'totalPinsKnocked': totalPinsKnocked,
      'highestGame': highestGame,
      'averageScore': averageScore,
      'totalStrikes': totalStrikes,
      'totalSpares': totalSpares,
      'perfectGames': perfectGames,
      'recentScores': recentScores,
      'consecutiveStrikes': consecutiveStrikes,
      'longestStrike': longestStrike,
      'achievements': achievements,
    };
  }
}
