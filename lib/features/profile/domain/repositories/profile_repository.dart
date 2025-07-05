import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';
import '../entities/game_record.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile();
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);
  Future<Either<Failure, UserProfile>> updateStatistics(
    UserStatistics statistics,
  );
  Future<Either<Failure, void>> saveGameResult({
    required int finalScore,
    required int strikes,
    required int spares,
    required int totalPins,
    required bool isPerfectGame,
  });

  // New game record methods
  Future<Either<Failure, void>> saveGameRecord(GameRecord gameRecord);
  Future<Either<Failure, List<GameRecord>>> getGameRecords();
  Future<Either<Failure, void>> deleteGameRecord(String gameId);
}
