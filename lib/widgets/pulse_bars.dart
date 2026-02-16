import 'package:flutter/material.dart';

class PulseBars extends StatelessWidget {
  final double luck;
  final double logic;
  final double speed;

  const PulseBars({
    super.key,
    required this.luck,
    required this.logic,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatRow(
          context,
          'LUCK',
          luck,
          Colors.pinkAccent,
          'A measure of how many times you picked the best node when faced with a choice.',
        ),
        const SizedBox(height: 16),
        _buildStatRow(
          context,
          'LOGIC',
          logic,
          Colors.blueAccent,
          'A measure of how many times you chose a node that could logically contain the heart.',
        ),
        const SizedBox(height: 16),
        _buildStatRow(
          context,
          'SPEED',
          speed,
          Colors.cyanAccent,
          'The speed at which you solved the puzzle.',
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    double value,
    Color color,
    String tooltip,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: tooltip,
          triggerMode: TooltipTriggerMode.tap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.8),
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.info_outline,
                    size: 10,
                    color: color.withValues(alpha: 0.5),
                  ),
                ],
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              height: 4,
              width: MediaQuery.of(context).size.width * value * 0.7, // scaled
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
