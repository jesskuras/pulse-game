import 'dart:math' as math;
import 'package:flutter/material.dart';

class TutorialOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const TutorialOverlay({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HEXTRA',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: onClose,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                'THE GOAL',
                'Find the hidden Heart ❤️ in the hexagonal web. There is a new puzzle every day.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'THE PULSE',
                'Tap any node to send a "Pulse". The number revealed is the SHORTEST PATH distance (jumps) to the heart.',
                icon: Icons.radar,
              ),
              const SizedBox(height: 24),
              const Text(
                'OBSTACLES',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _buildKeyItem(
                context,
                'RUPTURE',
                'Pink cross-bars. These connections are BROKEN and cannot be crossed.',
                _buildRuptureIcon(),
              ),
              const SizedBox(height: 16),
              _buildKeyItem(
                context,
                'SIGNAL DAMPENER',
                'Cyan wavy lines. These paths are HEAVY and count as exactly 2 jumps.',
                _buildWaveIcon(),
              ),
              const SizedBox(height: 16),
              _buildKeyItem(
                context,
                'STATIC INTERFERENCE',
                'Flickering nodes. Pinging these returns a FUZZY RANGE (e.g., 3-5) instead of an exact number.',
                _buildStaticIcon(),
              ),
              const SizedBox(height: 16),
              _buildKeyItem(
                context,
                'FADING SIGNAL',
                'Reveals distance for only 3 seconds, then VANISHES. You must remember it!',
                _buildFadingIcon(),
              ),
              const SizedBox(height: 48),
              Center(
                child: TextButton(
                  onPressed: onClose,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    side: const BorderSide(color: Colors.cyanAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'UNDERSTOOD',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String body, {
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyItem(
    BuildContext context,
    String title,
    String body,
    Widget visual,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: visual),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuptureIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(width: 30, height: 1.5, color: Colors.white24),
        Transform.rotate(
          angle: 1.57,
          child: Container(width: 25, height: 3, color: Colors.pinkAccent),
        ),
      ],
    );
  }

  Widget _buildWaveIcon() {
    return CustomPaint(size: const Size(30, 10), painter: _SingleWavePainter());
  }

  Widget _buildStaticIcon() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.pinkAccent, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.pinkAccent.withOpacity(0.5), blurRadius: 6),
        ],
      ),
    );
  }

  Widget _buildFadingIcon() {
    return Icon(
      Icons.timelapse,
      color: Colors.cyanAccent.withOpacity(0.7),
      size: 20,
    );
  }
}

class _SingleWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);

    // Simple sine wave path
    const count = 30;
    for (int i = 0; i <= count; i++) {
      final x = i * size.width / count;
      final y = size.height / 2 + 6 * math.sin(i / count * 2 * math.pi);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
