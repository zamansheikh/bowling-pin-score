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
                width: 65,
                height: 85,
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: widget.pin.isKnockedDown
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.red.shade400,
                            Colors.red.shade600,
                            Colors.red.shade800,
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.grey.shade100,
                            Colors.grey.shade200,
                          ],
                        ),
                  border: Border.all(
                    color: widget.pin.isKnockedDown
                        ? Colors.red.shade800
                        : Colors.grey.shade400,
                    width: 3,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(3, 4),
                    ),
                    if (!widget.pin.isKnockedDown)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 4,
                        offset: const Offset(-1, -1),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pin head (bowling ball icon or circle)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: widget.pin.isKnockedDown
                            ? LinearGradient(
                                colors: [
                                  Colors.red.shade300,
                                  Colors.red.shade500,
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade200,
                                  Colors.grey.shade400,
                                ],
                              ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.pin.isKnockedDown
                              ? Colors.red.shade900
                              : Colors.grey.shade600,
                          width: 1.5,
                        ),
                      ),
                      child: widget.pin.isKnockedDown
                          ? Icon(Icons.close, color: Colors.white, size: 14)
                          : Icon(
                              Icons.sports_baseball,
                              color: Colors.grey.shade700,
                              size: 12,
                            ),
                    ),
                    const SizedBox(height: 4),
                    // Pin number
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: widget.pin.isKnockedDown
                            ? Colors.red.shade900
                            : Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.pin.position}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Pin body stripes
                    if (!widget.pin.isKnockedDown) ...[
                      Container(
                        width: 18,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Container(
                        width: 14,
                        height: 1.5,
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ] else ...[
                      // Knocked down indicator
                      Icon(
                        Icons.clear_all,
                        color: Colors.red.shade200,
                        size: 14,
                      ),
                    ],
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
