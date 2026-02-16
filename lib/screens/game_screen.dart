import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/pulse_web.dart';
import '../widgets/stats_overlay.dart';
import '../widgets/tutorial_overlay.dart';
import '../services/storage_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showStats = true;
  bool _showTutorial = false;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final completed = await _storage.isTutorialCompleted();
    if (!completed) {
      if (mounted) {
        setState(() => _showTutorial = true);
      }
    }
  }

  void _hideTutorial() {
    setState(() => _showTutorial = false);
    _storage.setTutorialCompleted(true);
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final state = gameProvider.state;

    return Scaffold(
      body: Stack(
        children: [
          // Background Glow & Tap to Dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (state.isFound && _showStats) {
                  setState(() => _showStats = false);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Colors.cyan.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 48), // Spacer for centering
                    Text(
                      'HEXTRA',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Colors.white24,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _showTutorial = true),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  gameProvider.isAlreadyPlayed
                      ? 'ALREADY SCANNED'
                      : 'DAILY SCAN',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    letterSpacing: 4,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PulseWeb(
                        gridSize: state.gridSize,
                        onTap: (pos) => gameProvider.ping(pos),
                        state: state,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0, top: 20),
                  child: gameProvider.isAlreadyPlayed
                      ? const Text(
                          'COME BACK TOMORROW',
                          style: TextStyle(
                            color: Colors.white24,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          'PINGS: ${state.pings.length}',
                          style: const TextStyle(
                            color: Colors.white54,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Recall Stats Button
          if (state.isFound && !_showStats)
            Positioned(
              bottom: 40,
              right: 20,
              child: FloatingActionButton.small(
                backgroundColor: Colors.cyanAccent.withValues(alpha: 0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.cyanAccent, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () => setState(() => _showStats = true),
                child: const Icon(Icons.bar_chart, color: Colors.cyanAccent),
              ),
            ),

          // Stats Overlay
          if (state.isFound && gameProvider.lastResult != null && _showStats)
            GestureDetector(
              onTap: () => setState(() => _showStats = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: StatsOverlay(
                      luck: gameProvider.lastResult!.luck,
                      logic: gameProvider.lastResult!.logic,
                      speed: gameProvider.lastResult!.speed,
                    ),
                  ),
                ),
              ),
            ),

          // Tutorial Overlay
          if (_showTutorial) TutorialOverlay(onClose: _hideTutorial),
        ],
      ),
    );
  }
}
