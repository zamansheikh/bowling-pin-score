import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
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
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        height: 75,
        margin: const EdgeInsets.all(4),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: widget.pin.isKnockedDown
                    ? _rotationAnimation.value
                    : 0.0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Simple shadow at the bottom
                    Positioned(
                      bottom: 2,
                      child: Container(
                        width: 35,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Main SVG Pin - clean and simple
                    SvgPicture.asset(
                      widget.pin.isKnockedDown
                          ? 'assets/images/svg/bowling_pin_broken.svg'
                          : 'assets/images/svg/bowling_pin_normal.svg',
                      width: 50,
                      height: 65,
                      fit: BoxFit.contain,
                    ),

                    // Pin Number - clean design
                    Positioned(
                      bottom: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: widget.pin.isKnockedDown
                              ? Colors.red.shade600
                              : Colors.blue.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${widget.pin.position}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Simple status indicator for knocked down pins
                    if (widget.pin.isKnockedDown)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.red.shade500,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
