import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/game_record.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../models/user_profile_model.dart';
import '../models/game_record_model.dart';

@Injectable(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final profileModel = await localDataSource.getUserProfile();
      return Right(profileModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get user profile'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
    UserProfile profile,
  ) async {
    try {
      final profileModel = UserProfileModel.fromEntity(profile);
      await localDataSource.saveUserProfile(profileModel);
      return Right(profile);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to update user profile'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateStatistics(
    UserStatistics statistics,
  ) async {
    try {
      final statisticsModel = UserStatisticsModel.fromEntity(statistics);
      await localDataSource.updateStatistics(statisticsModel);
      final updatedProfile = await localDataSource.getUserProfile();
      return Right(updatedProfile.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to update statistics'));
    }
  }

  @override
  Future<Either<Failure, void>> saveGameResult({
    required int finalScore,
    required int strikes,
    required int spares,
    required int totalPins,
    required bool isPerfectGame,
  }) async {
    try {
      await localDataSource.saveGameResult(
        finalScore: finalScore,
        strikes: strikes,
        spares: spares,
        totalPins: totalPins,
        isPerfectGame: isPerfectGame,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to save game result'));
    }
  }

  @override
  Future<Either<Failure, void>> saveGameRecord(GameRecord gameRecord) async {
    try {
      final gameRecordModel = GameRecordModel.fromEntity(gameRecord);
      await localDataSource.saveGameRecord(gameRecordModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to save game record'));
    }
  }

  @override
  Future<Either<Failure, List<GameRecord>>> getGameRecords() async {
    try {
      final gameRecordModels = await localDataSource.getGameRecords();
      final gameRecords = gameRecordModels
          .map((model) => model.toEntity())
          .toList();
      return Right(gameRecords);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get game records'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGameRecord(String gameId) async {
    try {
      await localDataSource.deleteGameRecord(gameId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to delete game record'));
    }
  }
}
