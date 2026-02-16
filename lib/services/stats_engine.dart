import 'package:flutter/material.dart';
import '../models/game_state.dart';

class StatsResult {
  final double luck;
  final double logic;
  final double speed;

  StatsResult({required this.luck, required this.logic, required this.speed});
}

class StatsEngine {
  static StatsResult calculate(GameState state) {
    return StatsResult(
      luck: calculateLuck(state),
      logic: calculateLogic(state),
      speed: calculateSpeed(state),
    );
  }

  static double calculateLuck(GameState state) {
    if (state.pings.isEmpty) return 0.0;
    double cumulativeLuck = 0.0;
    int pingsCount = state.pings.length;

    for (int i = 0; i < pingsCount; i++) {
      int before = _countPossibleLocations(state, i);
      int after = _countPossibleLocations(state, i + 1);
      if (before > 1) {
        cumulativeLuck += (before - after) / (before - 1);
      }
    }
    return (cumulativeLuck / pingsCount).clamp(0.0, 1.0);
  }

  static double calculateLogic(GameState state) {
    if (state.pings.isEmpty) return 0.0;
    int logicalPings = 0;
    for (int i = 0; i < state.pings.length; i++) {
      if (_isLocationPossible(state.pings[i].position, state, i)) {
        logicalPings++;
      }
    }
    return (logicalPings / state.pings.length).clamp(0.0, 1.0);
  }

  static double calculateSpeed(GameState state) {
    if (state.startTime == null || state.endTime == null) return 0.0;
    final duration = state.endTime!.difference(state.startTime!).inSeconds;
    return (1.0 - (duration / 45.0)).clamp(0.0, 1.0);
  }

  // Dijkstra Shortest Path through unblocked edges with weights
  static int pathDistance(
    Offset start,
    Offset end,
    Set<String> blockedIds,
    Map<String, int> weights,
  ) {
    if (start == end) return 0;

    // Using a simple Map for distances and prioritizing the queue
    final distances = {start: 0};
    final pq = <(Offset, int)>[(start, 0)];
    final visited = <Offset>{};

    while (pq.isNotEmpty) {
      // Sort by distance (Dijkstra simple priority)
      pq.sort((a, b) => a.$2.compareTo(b.$2));
      final (current, dist) = pq.removeAt(0);

      if (visited.contains(current)) continue;
      visited.add(current);

      if (current == end) return dist;

      for (final neighbor in _getNeighbors(current)) {
        final edge = GameEdge(current, neighbor);
        if (blockedIds.contains(edge.id)) continue;

        final weight = weights[edge.id] ?? 1;
        final newDist = dist + weight;

        if (!distances.containsKey(neighbor) ||
            newDist < distances[neighbor]!) {
          distances[neighbor] = newDist;
          pq.add((neighbor, newDist));
        }
      }
    }
    return 99; // Unreachable
  }

  static bool _isLocationPossible(
    Offset pos,
    GameState state,
    int upToPingIndex,
  ) {
    for (int i = 0; i < upToPingIndex; i++) {
      final ping = state.pings[i];
      int dist = pathDistance(
        pos,
        ping.position,
        state.blockedEdges,
        state.edgeWeights,
      );

      if (ping.isFuzzy) {
        if (dist < ping.minDistance! || dist > ping.maxDistance!) return false;
      } else {
        if (dist != ping.distance) return false;
      }
    }
    return true;
  }

  static int _countPossibleLocations(GameState state, int upToPingIndex) {
    int count = 0;
    for (int q = -3; q <= 3; q++) {
      for (int r = -3; r <= 3; r++) {
        if (!state.isValidNode(q, r)) continue;
        if (_isLocationPossible(
          Offset(q.toDouble(), r.toDouble()),
          state,
          upToPingIndex,
        )) {
          count++;
        }
      }
    }
    return count;
  }

  static List<Offset> _getNeighbors(Offset pos) {
    int q = pos.dx.toInt();
    int r = pos.dy.toInt();
    final List<Offset> neighbors = [];
    final axialDirs = [(1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1)];

    for (final dir in axialDirs) {
      int nq = q + dir.$1;
      int nr = r + dir.$2;
      if (GameState(target: Offset.zero).isValidNode(nq, nr)) {
        neighbors.add(Offset(nq.toDouble(), nr.toDouble()));
      }
    }
    return neighbors;
  }
}
