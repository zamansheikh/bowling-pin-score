import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/game_record.dart';
import '../repositories/profile_repository.dart';

@injectable
class GetGameRecords {
  final ProfileRepository repository;

  GetGameRecords(this.repository);

  /// Get all game records
  Future<Either<Failure, List<GameRecord>>> call() async {
    return await repository.getGameRecords();
  }

  /// Get game records for a specific date
  Future<Either<Failure, List<GameRecord>>> getForDate(DateTime date) async {
    final result = await repository.getGameRecords();
    return result.fold((failure) => Left(failure), (records) {
      final targetDate = DateTime(date.year, date.month, date.day);
      final filteredRecords = records.where((record) {
        final recordDate = DateTime(
          record.playedAt.year,
          record.playedAt.month,
          record.playedAt.day,
        );
        return recordDate == targetDate;
      }).toList();
      return Right(filteredRecords);
    });
  }

  /// Get daily game summaries grouped by date
  Future<Either<Failure, List<DailyGameSummary>>> getDailySummaries() async {
    final result = await repository.getGameRecords();
    return result.fold((failure) => Left(failure), (records) {
      final Map<DateTime, List<GameRecord>> groupedRecords = {};

      for (final record in records) {
        final date = DateTime(
          record.playedAt.year,
          record.playedAt.month,
          record.playedAt.day,
        );

        if (!groupedRecords.containsKey(date)) {
          groupedRecords[date] = [];
        }
        groupedRecords[date]!.add(record);
      }

      final summaries = groupedRecords.entries
          .map((entry) => DailyGameSummary(date: entry.key, games: entry.value))
          .toList();

      // Sort by date (most recent first)
      summaries.sort((a, b) => b.date.compareTo(a.date));

      return Right(summaries);
    });
  }

  /// Get recent game records with a limit
  Future<Either<Failure, List<GameRecord>>> getRecentGames({
    int limit = 10,
  }) async {
    final result = await repository.getGameRecords();
    return result.fold((failure) => Left(failure), (records) {
      // Sort by playedAt date (most recent first)
      final sortedRecords = List<GameRecord>.from(records)
        ..sort((a, b) => b.playedAt.compareTo(a.playedAt));

      // Take only the requested number of records
      final recentRecords = sortedRecords.take(limit).toList();
      return Right(recentRecords);
    });
  }
}
