import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/stats_engine.dart';
import '../services/storage_service.dart';

class GameProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  GameState _state = GameState(target: const Offset(3, 3));
  GameState get state => _state;

  StatsResult? _lastResult;
  StatsResult? get lastResult => _lastResult;

  bool _isAlreadyPlayed = false;
  bool get isAlreadyPlayed => _isAlreadyPlayed;

  GameProvider() {
    _initGame();
  }

  Future<void> _initGame() async {
    final now = DateTime.now();
    final dateString = "${now.year}-${now.month}-${now.day}";

    // Check if already played
    final existingResult = await _storage.getTodayResult(dateString);
    if (existingResult != null) {
      _lastResult = existingResult;
      _isAlreadyPlayed = true;
      // We should still generate the maze for the board view
    }

    final seed = dateString.hashCode;
    final random = Random(seed);

    final nodes = <Offset>[];
    for (int q = -3; q <= 3; q++) {
      for (int r = -3; r <= 3; r++) {
        if (GameState(target: Offset.zero).isValidNode(q, r)) {
          nodes.add(Offset(q.toDouble(), r.toDouble()));
        }
      }
    }

    final target = nodes[random.nextInt(nodes.length)];

    // Generate Blocked and Weighted Edges and Static/Fading Nodes
    final blocked = <String>{};
    final weights = <String, int>{};
    final staticNodes = <Offset>{};
    final fadingNodes = <Offset>{};
    for (final node in nodes) {
      final rand = random.nextDouble();
      if (rand < 0.2) {
        // 20% chance of a node being Static (blurred)
        staticNodes.add(node);
      } else if (rand < 0.35) {
        // 15% chance of a node being Fading (memory)
        fadingNodes.add(node);
      }

      for (final neighbor in GameState(
        target: Offset.zero,
      ).getNeighbors(node)) {
        final edge = GameEdge(node, neighbor);
        final edgeRand = random.nextDouble();
        if (edgeRand < 0.12) {
          blocked.add(edge.id);
        } else if (edgeRand < 0.25) {
          // 13% chance of being "Heavy" (exactly weight 2)
          weights[edge.id] = 2;
        }
      }
    }

    _state = GameState(
      target: target,
      blockedEdges: blocked,
      edgeWeights: weights,
      staticNodes: staticNodes,
      fadingNodes: fadingNodes,
      revealedNodes: const {},
      isFound: _isAlreadyPlayed,
    );
    notifyListeners();
  }

  void ping(Offset position) {
    if (_state.isFound) return;

    // Pulse Revelation: Reveal node and its local graph
    final newRevealedNodes = Set<Offset>.from(_state.revealedNodes);
    newRevealedNodes.add(position);

    final newRevealedEdges = Set<String>.from(_state.revealedEdges);
    for (final neighbor in _state.getNeighbors(position)) {
      newRevealedNodes.add(neighbor);
      newRevealedEdges.add(GameEdge(position, neighbor).id);
    }

    final distance = StatsEngine.pathDistance(
      position,
      _state.target,
      _state.blockedEdges,
      _state.edgeWeights,
    );
    final isFound = distance == 0;

    int? minDistance;
    int? maxDistance;

    if (_state.staticNodes.contains(position) && !isFound) {
      // Deterministic fuzz based on date seed and position
      final now = DateTime.now();
      final dateString = "${now.year}-${now.month}-${now.day}";
      final fuzzSeed =
          dateString.hashCode ^
          position.dx.toInt() ^
          (position.dy.toInt() << 8);
      final fuzzRand = Random(fuzzSeed);

      // +/- 1 or +/- 0
      final offset = fuzzRand.nextInt(3) - 1; // -1, 0, 1
      minDistance = max(0, distance + offset);
      maxDistance = minDistance + 1 + fuzzRand.nextInt(2); // Range of 1 or 2
      if (distance < minDistance) minDistance = distance;
      if (distance > maxDistance) maxDistance = distance;
    }

    DateTime? startTime = _state.startTime ?? DateTime.now();
    DateTime? endTime = isFound ? DateTime.now() : null;

    final newPing = GamePing(
      position: position,
      distance: distance,
      timestamp: DateTime.now(),
      minDistance: minDistance,
      maxDistance: maxDistance,
    );

    _state = _state.copyWith(
      pings: [..._state.pings, newPing],
      isFound: isFound,
      startTime: startTime,
      endTime: endTime,
      revealedNodes: newRevealedNodes,
      revealedEdges: newRevealedEdges,
    );

    if (isFound) {
      _lastResult = StatsEngine.calculate(_state);
      final now = DateTime.now();
      final dateString = "${now.year}-${now.month}-${now.day}";
      _storage.saveResult(dateString, _lastResult!);
    }

    notifyListeners();
  }

  void reset() {
    _initGame();
  }
}
