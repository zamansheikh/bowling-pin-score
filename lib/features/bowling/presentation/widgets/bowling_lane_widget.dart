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
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
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
          const SizedBox(height: 20),
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
