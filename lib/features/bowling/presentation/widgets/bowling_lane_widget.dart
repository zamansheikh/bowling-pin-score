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
            Colors.brown.shade200,
            Colors.brown.shade100,
            Colors.brown.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown.shade400, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Lane header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.brown.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'BOWLING LANE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Pin formation (standard 10-pin setup)
          Column(
            children: [
              // Back row - Pin 7, 8, 9, 10
              _buildPinRow([7, 8, 9, 10]),
              const SizedBox(height: 8),

              // Third row - Pin 4, 5, 6
              _buildPinRow([4, 5, 6]),
              const SizedBox(height: 8),

              // Second row - Pin 2, 3
              _buildPinRow([2, 3]),
              const SizedBox(height: 8),

              // Front row - Pin 1
              _buildPinRow([1]),
            ],
          ),

          const SizedBox(height: 20),

          // Lane markings
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.brown.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),

          // Foul line
          Container(
            height: 2,
            width: double.infinity,
            color: Colors.red.shade600,
          ),

          const SizedBox(height: 16),

          // Instructions
          if (isInteractive)
            Text(
              'Tap pins to knock them down/stand them up',
              style: TextStyle(
                color: Colors.brown.shade700,
                fontSize: 14,
                fontStyle: FontStyle.italic,
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
