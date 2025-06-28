import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bowling_game.dart';
import '../entities/bowling_frame.dart';

abstract class BowlingRepository {
  Future<Either<Failure, BowlingGame>> getCurrentGame();
  Future<Either<Failure, BowlingGame>> startNewGame();
  Future<Either<Failure, BowlingGame>> updateFrame(BowlingFrame frame);
  Future<Either<Failure, BowlingGame>> resetCurrentFrame();
  Future<Either<Failure, void>> saveGame(BowlingGame game);
  Future<Either<Failure, List<BowlingGame>>> getGameHistory();
}
