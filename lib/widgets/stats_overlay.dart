import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import '../widgets/pulse_bars.dart';
import '../screens/stats_screen.dart';
import '../widgets/share_card.dart';

class StatsOverlay extends StatelessWidget {
  final double luck;
  final double logic;
  final double speed;

  const StatsOverlay({
    super.key,
    required this.luck,
    required this.logic,
    required this.speed,
  });

  Future<void> _shareResults(BuildContext context) async {
    final screenshotController = ScreenshotController();

    final date = DateTime.now();
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      // Capture the pretty image
      final imageBytes = await screenshotController.captureFromWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0A0E21),
            fontFamily: 'Inter',
          ),
          home: Scaffold(
            body: Center(
              child: ShareCard(
                luck: luck,
                logic: logic,
                speed: speed,
                date: dateString,
              ),
            ),
          ),
        ),
        delay: const Duration(milliseconds: 200),
        context: context,
      );

      // Share the bytes directly via XFile.fromData (web & mobile compatible)
      final String text = 'Connect with your intuition. Scan the pulse: TBD';

      await Share.shareXFiles([
        XFile.fromData(
          imageBytes,
          name: 'pulse_share.png',
          mimeType: 'image/png',
        ),
      ], text: text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing results: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'DAILY SNAPSHOT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'See you tomorrow for a new scan.',
            style: TextStyle(color: Colors.white30, fontSize: 12),
          ),
          const SizedBox(height: 32),
          // Assuming PulseBars is a widget that takes luck, logic, and speed
          // and displays them similar to the previous _buildStatRow logic.
          // This widget is not defined in the provided context, so it's
          // assumed to be defined elsewhere or imported.
          PulseBars(luck: luck, logic: logic, speed: speed),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareResults(context),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('SHARE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatsScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('LIFETIME'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
