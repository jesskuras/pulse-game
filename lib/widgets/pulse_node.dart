import 'package:flutter/material.dart';

class PulseNode extends StatefulWidget {
  final bool isPinged;
  final bool isTarget;
  final String? displayValue;
  final String? maxDisplayValue;
  final VoidCallback onTap;
  final bool isRevealed;
  final bool isStatic;
  final bool isFading;
  final DateTime? pingTimestamp;

  const PulseNode({
    super.key,
    required this.isPinged,
    required this.isTarget,
    this.displayValue,
    this.maxDisplayValue,
    required this.onTap,
    this.isRevealed = true,
    this.isStatic = false,
    this.isFading = false,
    this.pingTimestamp,
  });

  @override
  State<PulseNode> createState() => _PulseNodeState();
}

class _PulseNodeState extends State<PulseNode> with TickerProviderStateMixin {
  late AnimationController _staticController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _staticController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      value: 1.0, // Fully visible by default
    );

    if (widget.isFading && widget.pingTimestamp != null) {
      final elapsed = DateTime.now().difference(widget.pingTimestamp!);
      if (elapsed.inSeconds >= 3) {
        _fadeController.value = 0.0;
      } else {
        // Start fading from the correct point
        final remaining = const Duration(seconds: 3) - elapsed;
        _fadeController.value = remaining.inMilliseconds / 3000.0;
        _fadeController.reverse(from: _fadeController.value);
      }
    }
  }

  @override
  void didUpdateWidget(PulseNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFading &&
        widget.pingTimestamp != null &&
        oldWidget.pingTimestamp != widget.pingTimestamp) {
      _fadeController.reverse(from: 1.0);
    }
  }

  @override
  void dispose() {
    _staticController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_staticController, _fadeController]),
      builder: (context, child) {
        final isGlitched =
            widget.isStatic &&
            widget.isRevealed &&
            _staticController.value > 0.8;

        Color borderColor = widget.isPinged
            ? Colors.cyanAccent
            : (widget.isRevealed
                  ? Colors.white.withOpacity(0.45)
                  : Colors.white.withOpacity(0.22));

        if (widget.isTarget) borderColor = Colors.redAccent;
        if (isGlitched) borderColor = Colors.pinkAccent.withOpacity(0.6);

        final String label = widget.isTarget
            ? '❤️'
            : (widget.isPinged
                  ? (widget.maxDisplayValue != null &&
                            widget.displayValue != null
                        ? '${widget.displayValue}-${widget.maxDisplayValue}'
                        : (widget.displayValue ?? ''))
                  : '');

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.isPinged
                  ? Colors.cyan.withOpacity(0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: widget.isPinged ? 2.0 : 1.0,
              ),
              boxShadow: widget.isPinged
                  ? [
                      BoxShadow(
                        color:
                            (isGlitched ? Colors.pinkAccent : Colors.cyanAccent)
                                .withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Opacity(
                opacity: widget.isFading ? _fadeController.value : 1.0,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isGlitched ? Colors.pinkAccent : Colors.cyanAccent,
                    fontSize: widget.maxDisplayValue != null ? 12 : 16,
                    fontWeight: FontWeight.bold,
                    shadows: widget.maxDisplayValue != null
                        ? [
                            const Shadow(
                              color: Colors.cyanAccent,
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
