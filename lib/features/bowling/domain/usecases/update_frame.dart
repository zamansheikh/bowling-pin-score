import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bowling_frame.dart';
import '../entities/bowling_game.dart';
import '../repositories/bowling_repository.dart';

@injectable
class UpdateFrame {
  final BowlingRepository repository;

  UpdateFrame(this.repository);

  Future<Either<Failure, BowlingGame>> call(BowlingFrame frame) async {
    return await repository.updateFrame(frame);
  }
}
