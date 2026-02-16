import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_game/models/game_state.dart';
import 'package:lucky_game/services/stats_engine.dart';

void main() {
  group('StatsEngine Tests', () {
    test('Logic calculation should return positive for finding target', () {
      final target = const Offset(3, 3);
      final state = GameState(target: target, gridSize: 7);

      // First ping at (3,3) - instant find
      final ping = GamePing(
        position: const Offset(3, 3),
        distance: 0,
        timestamp: DateTime.now(),
      );

      final stateFound = state.copyWith(pings: [ping], isFound: true);

      final logic = StatsEngine.calculateLogic(stateFound);
      expect(logic, 1.0);
    });

    test('Luck calculation should be based on search space reduction', () {
      final target = const Offset(0, 0);
      final state = GameState(target: target, gridSize: 7);

      // Ping at (0,0) immediately finds it.
      // Total nodes in radius 3 = 37.
      // before=37, after=1. Luck = 36/36 = 1.0
      final state1 = state.copyWith(
        pings: [
          GamePing(
            position: const Offset(0, 0),
            distance: 0,
            timestamp: DateTime.now(),
          ),
        ],
        isFound: true,
      );
      expect(StatsEngine.calculateLuck(state1), closeTo(1.0, 0.001));
    });

    test('Pathfinding BFS should calculate correct distances', () {
      const blocked = <String>{}; // No blocks
      const weights = <String, int>{};
      final start = const Offset(0, 0);
      final neighbor = const Offset(1, 0);
      final far = const Offset(2, 0);

      expect(StatsEngine.pathDistance(start, neighbor, blocked, weights), 1);
      expect(StatsEngine.pathDistance(start, far, blocked, weights), 2);
    });

    test('Pathfinding should respect blocked edges', () {
      // (0,0) to (1,0) is blocked
      final edge = GameEdge(const Offset(0, 0), const Offset(1, 0));
      final blocked = {edge.id};
      const weights = <String, int>{};

      final start = const Offset(0, 0);
      final end = const Offset(1, 0);

      // Should take a detour: (0,0) -> (1,-1) -> (1,0) = 2 hops
      expect(StatsEngine.pathDistance(start, end, blocked, weights), 2);
    });

    test('Pathfinding should respect weighted edges', () {
      final start = const Offset(0, 0);
      final end = const Offset(1, 0);
      final edge = GameEdge(start, end);

      // Direct path is weighted 3
      final weights = {edge.id: 3};
      const blocked = <String>{};

      // Direct path cost 3 vs detour cost 2: (0,0) -> (1,-1) -> (1,0)
      expect(StatsEngine.pathDistance(start, end, blocked, weights), 2);
    });

    test('Speed calculation should decrease reaching 0 at 45s', () {
      final now = DateTime.now();
      final state = GameState(
        target: Offset.zero,
        gridSize: 7,
        startTime: now,
        endTime: now.add(const Duration(seconds: 15)),
      );

      // (1.0 - 15/45) = 0.666
      expect(StatsEngine.calculateSpeed(state), closeTo(0.666, 0.01));
    });
  });
}
