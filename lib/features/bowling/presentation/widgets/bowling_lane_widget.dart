import 'package:flutter/material.dart';
import '../../domain/entities/bowling_pin.dart';
import 'bowling_pin_widget.dart';

class BowlingLaneWidget extends StatelessWidget {
  final List<BowlingPin> pins;
  final Function(int) onPinTapped;
  final bool isInteractive;

  const BowlingLaneWidget({
    super.key,
    required this.pins,
    required this.onPinTapped,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          // Lane header with better styling
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.brown.shade900, Colors.brown.shade700],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'BOWLING LANE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Pin formation with better spacing
          Column(
            children: [
              // Back row - Pin 7, 8, 9, 10
              _buildPinRow([7, 8, 9, 10]),
              const SizedBox(height: 12),

              // Third row - Pin 4, 5, 6
              _buildPinRow([4, 5, 6]),
              const SizedBox(height: 12),

              // Second row - Pin 2, 3
              _buildPinRow([2, 3]),
              const SizedBox(height: 12),

              // Front row - Pin 1
              _buildPinRow([1]),
            ],
          ),

          const SizedBox(height: 30),

          // Improved lane markings
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.brown.shade800, Colors.brown.shade600],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Enhanced foul line
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.red.shade500],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Enhanced instructions
          if (isInteractive)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                border: Border.all(color: Colors.brown.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, color: Colors.brown.shade700, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Tap pins to knock them down or stand them up',
                      style: TextStyle(
                        color: Colors.brown.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPinRow(List<int> pinNumbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pinNumbers.map((pinNumber) {
        final pin = pins.firstWhere(
          (p) => p.position == pinNumber,
          orElse: () => BowlingPin(position: pinNumber),
        );

        return BowlingPinWidget(
          pin: pin,
          onTap: () => onPinTapped(pinNumber),
          isInteractive: isInteractive,
        );
      }).toList(),
    );
  }
}
