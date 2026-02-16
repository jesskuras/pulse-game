import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/storage_service.dart';
import '../widgets/pulse_bars.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'LIFETIME STATS',
          style: TextStyle(
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, double>>(
        future: storage.getLifetimeStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data!;
          final count = stats['count']?.toInt() ?? 0;

          if (count == 0) {
            return const Center(
              child: Text(
                'NO SCANS RECORDED YET',
                style: TextStyle(color: Colors.white54, letterSpacing: 2),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$count SCAN${count == 1 ? '' : 'S'} COMPLETED',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 18,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                PulseBars(
                  luck: stats['luck'] ?? 0,
                  logic: stats['logic'] ?? 0,
                  speed: stats['speed'] ?? 0,
                ),
                const SizedBox(height: 64),
                const Text(
                  'Your performance is averaged over\nevery daily scan you have completed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                TextButton.icon(
                  onPressed: () =>
                      launchUrl(Uri.parse('https://ko-fi.com/jesskuras')),
                  icon: const Icon(
                    Icons.coffee,
                    color: Colors.white24,
                    size: 16,
                  ),
                  label: const Text(
                    'Support the Dev',
                    style: TextStyle(
                      color: Colors.white24,
                      letterSpacing: 1,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
