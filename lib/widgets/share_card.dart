import 'package:flutter/material.dart';
import 'pulse_bars.dart';

class ShareCard extends StatelessWidget {
  final double luck;
  final double logic;
  final double speed;
  final String date;

  const ShareCard({
    super.key,
    required this.luck,
    required this.logic,
    required this.speed,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'PULSE',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'DAILY SCAN: $date',
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 12,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),
          PulseBars(luck: luck, logic: logic, speed: speed),
          const SizedBox(height: 64),
          const Text(
            'Can you beat my score?',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Download Pulse in the App Store',
            style: TextStyle(color: Colors.white24, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
