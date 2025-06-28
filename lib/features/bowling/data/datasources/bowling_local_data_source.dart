import '../models/bowling_frame_model.dart';
import '../../domain/entities/bowling_game.dart';

abstract class BowlingLocalDataSource {
  Future<BowlingGame> getCurrentGame();
  Future<BowlingGame> startNewGame();
  Future<BowlingGame> updateFrame(BowlingFrameModel frame);
  Future<void> saveGame(BowlingGame game);
  Future<List<BowlingGame>> getGameHistory();
}
