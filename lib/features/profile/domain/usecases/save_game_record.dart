import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/game_record.dart';
import '../repositories/profile_repository.dart';

@injectable
class SaveGameRecord {
  final ProfileRepository repository;

  SaveGameRecord(this.repository);

  Future<Either<Failure, void>> call({
    required int finalScore,
    required int strikes,
    required int spares,
    required int totalPins,
    required bool isPerfectGame,
    required List<int> frameScores,
    required Duration gameDuration,
    DateTime? playedAt, // Optional, defaults to now
  }) async {
    final gameRecord = GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      score: finalScore,
      strikes: strikes,
      spares: spares,
      totalPins: totalPins,
      isPerfectGame: isPerfectGame,
      playedAt: playedAt ?? DateTime.now(),
      frameScores: frameScores,
      gameDuration: gameDuration,
    );

    return await repository.saveGameRecord(gameRecord);
  }
}
