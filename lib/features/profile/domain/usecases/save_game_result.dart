import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

@injectable
class SaveGameResult {
  final ProfileRepository repository;

  SaveGameResult(this.repository);

  Future<Either<Failure, void>> call({
    required int finalScore,
    required int strikes,
    required int spares,
    required int totalPins,
    required bool isPerfectGame,
  }) async {
    return await repository.saveGameResult(
      finalScore: finalScore,
      strikes: strikes,
      spares: spares,
      totalPins: totalPins,
      isPerfectGame: isPerfectGame,
    );
  }
}
