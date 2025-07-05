import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/app_router.dart';
import '../widgets/bowling_lane_widget.dart';
import '../../domain/entities/bowling_pin.dart';

class BowlingDemoPage extends StatefulWidget {
  const BowlingDemoPage({super.key});

  @override
  State<BowlingDemoPage> createState() => _BowlingDemoPageState();
}

class _BowlingDemoPageState extends State<BowlingDemoPage> {
  List<BowlingPin> pins = [];

  @override
  void initState() {
    super.initState();
    _resetPins();
  }

  void _resetPins() {
    setState(() {
      pins = List.generate(10, (index) => BowlingPin(position: index + 1));
    });
  }

  void _togglePin(int position) {
    setState(() {
      pins = pins.map((pin) {
        if (pin.position == position) {
          return pin.isKnockedDown ? pin.reset() : pin.knockDown();
        }
        return pin;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎳 Visual Bowling Pin Interface'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go(AppRoutes.profile),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(AppRoutes.settings),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.gamepad_outlined),
            onPressed: () => context.go(AppRoutes.fullGame),
            tooltip: 'Full Game Mode',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Current score display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.brown.shade300,
                    Colors.brown.shade200,
                    Colors.brown.shade100,
                    Colors.brown.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.brown.shade600, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'CURRENT ROLL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pins Down: ${pins.where((p) => p.isKnockedDown).length}/10',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Interactive bowling lane
            BowlingLaneWidget(
              pins: pins,
              onPinTapped: _togglePin,
              isInteractive: true,
            ),

            const SizedBox(height: 24),

            // Control buttons - three button layout
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetPins,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        pins = pins.map((pin) => pin.reset()).toList();
                      });
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 20),
                    label: const Text(
                      'Miss',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        pins = pins.map((pin) => pin.knockDown()).toList();
                      });
                    },
                    icon: const Icon(Icons.bolt, size: 20),
                    label: const Text(
                      'Strike!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Features showcase
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ FEATURES',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    '🎯',
                    'Visual pin layout in standard 10-pin formation',
                  ),
                  _buildFeatureItem('✋', 'Tap to knock down/stand up pins'),
                  _buildFeatureItem('⚡', 'Quick Strike button for all pins'),
                  _buildFeatureItem('❌', 'Miss button for gutter balls'),
                  _buildFeatureItem(
                    '🎨',
                    'Smooth animations and visual feedback',
                  ),
                  _buildFeatureItem('🏆', 'No manual number input required'),
                  _buildFeatureItem('📊', 'Real-time score calculation'),
                  _buildFeatureItem('🎳', 'Professional bowling lane design'),
                  _buildFeatureItem(
                    '👤',
                    'Player profile with statistics & achievements',
                  ),
                  _buildFeatureItem('📈', 'Track your progress over time'),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: "fullGame",
            onPressed: () => context.go(AppRoutes.fullGame),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.sports_score),
            label: const Text('Play Full Game'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.green.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
