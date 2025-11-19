import 'package:flutter/material.dart';

class VictoryScreenWidget extends StatefulWidget {
  final String message;
  final int expGained;
  final int starsEarned;
  final bool isPracticeMode;
  final VoidCallback onContinue;

  const VictoryScreenWidget({
    super.key,
    required this.message,
    required this.expGained,
    required this.starsEarned,
    this.isPracticeMode = false,
    required this.onContinue,
  });

  @override
  State<VictoryScreenWidget> createState() => _VictoryScreenWidgetState();
}

class _VictoryScreenWidgetState extends State<VictoryScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0a0a0a),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              color: const Color(0xFF1e1e1e),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        size: 60,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Victory text
                    Text(
                      widget.isPracticeMode
                          ? 'PRACTICE COMPLETE'
                          : widget.message.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Rewards section
                    if (!widget.isPracticeMode)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a2a),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'REWARDS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 48,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '+${widget.expGained}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    const Text(
                                      'EXP',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      '⭐',
                                      style: TextStyle(fontSize: 36),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '+${widget.starsEarned}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9C27B0),
                                      ),
                                    ),
                                    const Text(
                                      'STARS',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a2a),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, color: Colors.orange, size: 20),
                            SizedBox(width: 12),
                            Text(
                              'No rewards earned',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: widget.onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'CONTINUE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DefeatScreenWidget extends StatefulWidget {
  final VoidCallback onContinue;

  const DefeatScreenWidget({super.key, required this.onContinue});

  @override
  State<DefeatScreenWidget> createState() => _DefeatScreenWidgetState();
}

class _DefeatScreenWidgetState extends State<DefeatScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0a0a0a),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              color: const Color(0xFF1e1e1e),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: Colors.red.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Static X icon for defeat
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 60,
                        color: Colors.red[300],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Defeat text
                    Text(
                      'DEFEATED',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[400],
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Better luck next time',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white54,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Retry button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: widget.onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'RETRY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
