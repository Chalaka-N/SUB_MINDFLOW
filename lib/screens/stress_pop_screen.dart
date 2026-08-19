import 'package:flutter/material.dart';
import '../services/analytics_service.dart'; // 👈 1. Analytics service imported

class StressPopScreen extends StatefulWidget {
  const StressPopScreen({super.key});

  @override
  State<StressPopScreen> createState() => _StressPopScreenState();
}

class _StressPopScreenState extends State<StressPopScreen> {
  // 🎈 PSYC FACT: We start with a large, daunting grid to match the user's tension.
  // 108 bubbles (12 rows x 9 columns) - perfect for laptops.
  late List<bool> _bubbleStates;
  final int _totalBubbles = 108;
  int _poppedCount = 0;
  bool _hasLoggedUsage = false; // Ensures we log once per session

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _bubbleStates = List.generate(_totalBubbles, (_) => false);
      _poppedCount = 0;
      _hasLoggedUsage = false; // Reset log flag on new game
    });
  }

  // 🎈 PSYC FACT: Rapid, shallow interaction gives a kinetic release of adrenaline.
  Future<void> _popBubble(int index) async {
    if (!_bubbleStates[index]) {
      // 📊 Automatically log SOS usage on the first bubble pop of the session!
      if (!_hasLoggedUsage) {
        _hasLoggedUsage = true;
        await AnalyticsService.logSOSUsage();
      }

      setState(() {
        _bubbleStates[index] = true;
        _poppedCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2A4A), // Solid Navy background for focus
      appBar: AppBar(
        title: const Text('MindFlow :: Stress Pop',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D2A4A),
        foregroundColor: Colors.white,
        elevation: 0,
        // Close button to exit back to Home immediately
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetGame,
            tooltip: 'Reset Bubbles',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Instructions
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Just Pop.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$_poppedCount / $_totalBubbles',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA5C953), // Leaf Green for progress
                  ),
                ),
              ],
            ),
          ),

          // The Stress Pop Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                // 9 columns for laptop screens
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _totalBubbles,
                itemBuilder: (context, index) {
                  final isPopped = _bubbleStates[index];
                  // Assign comforting theme colors to the unpopped bubbles
                  final List<Color> bubbleColors = [
                    const Color(0xFF2CB5C0), // Teal
                    const Color(0xFFA5C953), // Green
                    const Color(0xFF9163A6), // Purple
                  ];
                  final Color currentBubbleColor =
                      bubbleColors[index % bubbleColors.length];

                  return GestureDetector(
                    // 🎈 PSYC FACT: No complex logic. Click = satisfaction.
                    onTapDown: (_) => _popBubble(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        // 🎈 PSYC FACT: Popped bubbles turn Navy, "disappearing" into the void
                        color: isPopped ? const Color(0xFF0D2A4A) : currentBubbleColor,
                        shape: BoxShape.circle,
                        border: isPopped
                            ? Border.all(color: Colors.white.withOpacity(0.1), width: 1)
                            : Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                        boxShadow: isPopped
                            ? []
                            : [
                                BoxShadow(
                                  color: currentBubbleColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}