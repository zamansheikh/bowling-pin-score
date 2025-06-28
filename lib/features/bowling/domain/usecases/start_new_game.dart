import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bowling_game.dart';
import '../repositories/bowling_repository.dart';

@injectable
class StartNewGame {
  final BowlingRepository repository;

  StartNewGame(this.repository);

  Future<Either<Failure, BowlingGame>> call() async {
    return await repository.startNewGame();
  }
}
