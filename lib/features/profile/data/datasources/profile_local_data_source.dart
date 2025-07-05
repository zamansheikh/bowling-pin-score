import '../models/user_profile_model.dart';
import '../models/game_record_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<void> saveUserProfile(UserProfileModel profile);
  Future<void> updateStatistics(UserStatisticsModel statistics);
  Future<void> saveGameResult({
    required int finalScore,
    required int strikes,
    required int spares,
    required int totalPins,
    required bool isPerfectGame,
  });

  // New game record methods
  Future<void> saveGameRecord(GameRecordModel gameRecord);
  Future<List<GameRecordModel>> getGameRecords();
  Future<void> deleteGameRecord(String gameId);
}
