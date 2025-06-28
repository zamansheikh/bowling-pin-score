import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/bowling_game.dart';
import '../../domain/entities/bowling_frame.dart';
import '../../domain/repositories/bowling_repository.dart';
import '../datasources/bowling_local_data_source.dart';
import '../models/bowling_frame_model.dart';

@Injectable(as: BowlingRepository)
class BowlingRepositoryImpl implements BowlingRepository {
  final BowlingLocalDataSource localDataSource;

  BowlingRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, BowlingGame>> getCurrentGame() async {
    try {
      final game = await localDataSource.getCurrentGame();
      return Right(game);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, BowlingGame>> startNewGame() async {
    try {
      final game = await localDataSource.startNewGame();
      return Right(game);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to start new game'));
    }
  }

  @override
  Future<Either<Failure, BowlingGame>> updateFrame(BowlingFrame frame) async {
    try {
      final frameModel = BowlingFrameModel.fromEntity(frame);
      final game = await localDataSource.updateFrame(frameModel);
      return Right(game);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to update frame'));
    }
  }

  @override
  Future<Either<Failure, BowlingGame>> resetCurrentFrame() async {
    try {
      final currentGame = await localDataSource.getCurrentGame();
      if (currentGame.currentFrame != null) {
        final resetFrame = currentGame.currentFrame!.resetPins();
        return await updateFrame(resetFrame);
      }
      return Right(currentGame);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to reset frame'));
    }
  }

  @override
  Future<Either<Failure, void>> saveGame(BowlingGame game) async {
    try {
      await localDataSource.saveGame(game);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to save game'));
    }
  }

  @override
  Future<Either<Failure, List<BowlingGame>>> getGameHistory() async {
    try {
      final games = await localDataSource.getGameHistory();
      return Right(games);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get game history'));
    }
  }
}
