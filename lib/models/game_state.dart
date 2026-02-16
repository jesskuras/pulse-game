import 'package:flutter/material.dart';

class GamePing {
  final Offset position;
  final int distance; // Shortest path distance
  final DateTime timestamp;
  final int? minDistance; // For fuzzy signals
  final int? maxDistance; // For fuzzy signals

  GamePing({
    required this.position,
    required this.distance,
    required this.timestamp,
    this.minDistance,
    this.maxDistance,
  });

  bool get isFuzzy => minDistance != null && maxDistance != null;
}

class GameEdge {
  final Offset a;
  final Offset b;
  final bool isBlocked;

  GameEdge(this.a, this.b, {this.isBlocked = false});

  String get id {
    final q1 = a.dx.toInt();
    final r1 = a.dy.toInt();
    final q2 = b.dx.toInt();
    final r2 = b.dy.toInt();
    if (q1 < q2 || (q1 == q2 && r1 < r2)) {
      return '$q1,$r1|$q2,$r2';
    } else {
      return '$q2,$r2|$q1,$r1';
    }
  }

  bool contains(Offset pos) => a == pos || b == pos;
  Offset other(Offset pos) => a == pos ? b : a;
}

class GameState {
  final int gridSize;
  final Offset target;
  final List<GamePing> pings;
  final bool isFound;
  final DateTime? startTime;
  final DateTime? endTime;

  // Fog of War & Maze state
  final Set<Offset> revealedNodes;
  final Set<String> revealedEdges;
  final Set<String> blockedEdges; // IDs of blocked edges
  final Map<String, int> edgeWeights; // Edge ID -> Weight (default 1)
  final Set<Offset> staticNodes; // Corrupted nodes (fuzzy distance)
  final Set<Offset> fadingNodes; // Memory nodes (fade after 3s)

  GameState({
    required this.target,
    this.gridSize = 7,
    this.pings = const [],
    this.isFound = false,
    this.startTime,
    this.endTime,
    this.revealedNodes = const {},
    this.revealedEdges = const {},
    this.blockedEdges = const {},
    this.edgeWeights = const {},
    this.staticNodes = const {},
    this.fadingNodes = const {},
  });

  GameState copyWith({
    Offset? target,
    int? gridSize,
    List<GamePing>? pings,
    bool? isFound,
    DateTime? startTime,
    DateTime? endTime,
    Set<Offset>? revealedNodes,
    Set<String>? revealedEdges,
    Set<String>? blockedEdges,
    Map<String, int>? edgeWeights,
    Set<Offset>? staticNodes,
    Set<Offset>? fadingNodes,
  }) {
    return GameState(
      target: target ?? this.target,
      gridSize: gridSize ?? this.gridSize,
      pings: pings ?? this.pings,
      isFound: isFound ?? this.isFound,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      revealedNodes: revealedNodes ?? this.revealedNodes,
      revealedEdges: revealedEdges ?? this.revealedEdges,
      blockedEdges: blockedEdges ?? this.blockedEdges,
      edgeWeights: edgeWeights ?? this.edgeWeights,
      staticNodes: staticNodes ?? this.staticNodes,
      fadingNodes: fadingNodes ?? this.fadingNodes,
    );
  }

  int hexDistance(Offset a, Offset b) {
    int q1 = a.dx.toInt();
    int r1 = a.dy.toInt();
    int q2 = b.dx.toInt();
    int r2 = b.dy.toInt();
    return ((q1 - q2).abs() + (q1 + r1 - q2 - r2).abs() + (r1 - r2).abs()) ~/ 2;
  }

  bool isValidNode(int q, int r) {
    int s = -q - r;
    return q.abs() <= 3 && r.abs() <= 3 && s.abs() <= 3;
  }

  List<Offset> getNeighbors(Offset pos) {
    int q = pos.dx.toInt();
    int r = pos.dy.toInt();
    final List<Offset> neighbors = [];
    const axialDirs = [(1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1), (0, 1)];

    for (final dir in axialDirs) {
      int nq = q + dir.$1;
      int nr = r + dir.$2;
      if (isValidNode(nq, nr)) {
        neighbors.add(Offset(nq.toDouble(), nr.toDouble()));
      }
    }
    return neighbors;
  }
}
