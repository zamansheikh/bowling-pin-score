import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bowling_game.dart';
import '../repositories/bowling_repository.dart';

@injectable
class GetCurrentGame {
  final BowlingRepository repository;

  GetCurrentGame(this.repository);

  Future<Either<Failure, BowlingGame>> call() async {
    return await repository.getCurrentGame();
  }
}
