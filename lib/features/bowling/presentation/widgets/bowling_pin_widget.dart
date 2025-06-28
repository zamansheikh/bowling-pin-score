import 'package:flutter/material.dart';
import '../../domain/entities/bowling_pin.dart';

class BowlingPinWidget extends StatefulWidget {
  final BowlingPin pin;
  final VoidCallback onTap;
  final bool isInteractive;

  const BowlingPinWidget({
    super.key,
    required this.pin,
    required this.onTap,
    this.isInteractive = true,
  });

  @override
  State<BowlingPinWidget> createState() => _BowlingPinWidgetState();
}

class _BowlingPinWidgetState extends State<BowlingPinWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Animate based on pin state
    if (widget.pin.isKnockedDown) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void didUpdateWidget(BowlingPinWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pin.isKnockedDown != widget.pin.isKnockedDown) {
      if (widget.pin.isKnockedDown) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isInteractive ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 40,
                height: 60,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.pin.isKnockedDown
                      ? Colors.red.shade300
                      : Colors.white,
                  border: Border.all(
                    color: widget.pin.isKnockedDown
                        ? Colors.red.shade600
                        : Colors.grey.shade600,
                    width: 2,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pin head
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: widget.pin.isKnockedDown
                            ? Colors.red.shade400
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Pin number
                    Text(
                      '${widget.pin.position}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.pin.isKnockedDown
                            ? Colors.red.shade800
                            : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Pin body lines
                    Container(
                      width: 12,
                      height: 2,
                      color: widget.pin.isKnockedDown
                          ? Colors.red.shade400
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 8,
                      height: 2,
                      color: widget.pin.isKnockedDown
                          ? Colors.red.shade400
                          : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
