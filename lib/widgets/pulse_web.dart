import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'pulse_node.dart';

class PulseWeb extends StatelessWidget {
  final int gridSize;
  final Function(Offset) onTap;
  final GameState state;

  const PulseWeb({
    super.key,
    required this.gridSize,
    required this.onTap,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final Offset center = Offset(width / 2, height / 2);
        final double spacing = width / (7 * 1.732 / 1.1);

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: WebConnectionsPainter(
                  gridSize: gridSize,
                  spacing: spacing,
                  state: state,
                ),
              ),
              for (int q = -3; q <= 3; q++)
                for (int r = -3; r <= 3; r++)
                  if (state.isValidNode(q, r))
                    Builder(
                      builder: (context) {
                        final pos = Offset(q.toDouble(), r.toDouble());
                        final isRevealed =
                            state.revealedNodes.contains(pos) || state.isFound;
                        final isStatic = state.staticNodes.contains(pos);
                        final isFading = state.fadingNodes.contains(pos);

                        double px =
                            center.dx + spacing * (1.732 * q + 1.732 / 2 * r);
                        double py = center.dy + spacing * (3 / 2 * r);

                        final ping = state.pings.any((p) => p.position == pos)
                            ? state.pings.firstWhere((p) => p.position == pos)
                            : null;
                        final isTarget = pos == state.target && state.isFound;

                        return Positioned(
                          left: px - 22,
                          top: py - 22,
                          child: PulseNode(
                            isPinged: ping != null,
                            isTarget: isTarget,
                            isRevealed: isRevealed,
                            isStatic: isStatic,
                            isFading: isFading,
                            pingTimestamp: ping?.timestamp,
                            displayValue:
                                ping?.minDistance?.toString() ??
                                ping?.distance.toString(),
                            maxDisplayValue: ping?.maxDistance?.toString(),
                            onTap: () => onTap(pos),
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}

class WebConnectionsPainter extends CustomPainter {
  final int gridSize;
  final double spacing;
  final GameState state;

  WebConnectionsPainter({
    required this.gridSize,
    required this.spacing,
    required this.state,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    final ghostPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    final revealedPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    final blockedPaint = Paint()
      ..color = Colors.pinkAccent.withValues(alpha: 0.4)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.3)
      ..strokeWidth = 2.0;

    for (int q = -3; q <= 3; q++) {
      for (int r = -3; r <= 3; r++) {
        if (!state.isValidNode(q, r)) continue;

        double cx = center.dx + spacing * (1.732 * q + 1.732 / 2 * r);
        double cy = center.dy + spacing * (3 / 2 * r);
        final current = Offset(cx, cy);

        final neighbors = [
          Offset((q + 1).toDouble(), r.toDouble()),
          Offset((q).toDouble(), (r + 1).toDouble()),
          Offset((q - 1).toDouble(), (r + 1).toDouble()),
        ];

        for (final neighbor in neighbors) {
          if (state.isValidNode(neighbor.dx.toInt(), neighbor.dy.toInt())) {
            final edge = GameEdge(Offset(q.toDouble(), r.toDouble()), neighbor);

            double nx =
                center.dx +
                spacing * (1.732 * neighbor.dx + 1.732 / 2 * neighbor.dy);
            double ny = center.dy + spacing * (3 / 2 * neighbor.dy);
            final next = Offset(nx, ny);

            final isRevealed =
                state.revealedEdges.contains(edge.id) || state.isFound;

            if (!isRevealed) {
              canvas.drawLine(current, next, ghostPaint);
            } else {
              if (state.blockedEdges.contains(edge.id)) {
                _drawRupture(canvas, current, next, blockedPaint);
              } else {
                bool isActive = _isEdgeActive(edge.a, edge.b);
                final weight = state.edgeWeights[edge.id] ?? 1;

                if (weight > 1) {
                  // Draw "Heavy" wavy line
                  _drawWavyLine(
                    canvas,
                    current,
                    next,
                    isActive ? activePaint : revealedPaint,
                  );
                } else {
                  canvas.drawLine(
                    current,
                    next,
                    isActive ? activePaint : revealedPaint,
                  );
                }
              }
            }
          }
        }
      }
    }
  }

  void _drawWavyLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final Path path = Path();
    path.moveTo(p1.dx, p1.dy);

    final distance = (p2 - p1).distance;
    final direction = (p2 - p1) / distance;
    final normal = Offset(-direction.dy, direction.dx);

    const waveCount = 4;
    const amplitude = 3.0;

    for (int i = 1; i <= 20; i++) {
      final t = i / 20;
      final point = Offset.lerp(p1, p2, t)!;
      final offset = normal * amplitude * math.sin(t * waveCount * 2 * math.pi);
      path.lineTo(point.dx + offset.dx, point.dy + offset.dy);
    }

    final wavyPaint = Paint()
      ..color = paint.color
      ..strokeWidth = paint.strokeWidth * 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, wavyPaint);
  }

  void _drawRupture(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final center = (p1 + p2) / 2;
    final direction = p2 - p1;
    final unit = direction / direction.distance;
    final normal = Offset(-unit.dy, unit.dx);

    const barLength = 8.0;
    final barStart = center + normal * barLength;
    final barEnd = center - normal * barLength;

    canvas.drawLine(barStart, barEnd, paint);
  }

  bool _isEdgeActive(Offset a, Offset b) {
    bool aPinged = state.pings.any((p) => p.position == a);
    bool bPinged = state.pings.any((p) => p.position == b);
    return aPinged && bPinged;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
