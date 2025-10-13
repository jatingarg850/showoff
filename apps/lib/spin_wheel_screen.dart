import 'dart:math';
import 'package:flutter/material.dart';

class SpinWheelScreen
    extends
        StatefulWidget {
  const SpinWheelScreen({
    super.key,
  });

  @override
  State<
    SpinWheelScreen
  >
  createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState
    extends
        State<
          SpinWheelScreen
        >
    with
        TickerProviderStateMixin {
  late AnimationController
  _controller;
  late Animation<
    double
  >
  _animation;
  bool
  _isSpinning = false;
  int
  _spinsLeft = 5;
  int
  _totalSpins = 5;

  final List<
    int
  >
  _wheelValues = [
    50,
    5,
    50,
    5,
    10,
    5,
    20,
    10,
  ];
  final List<
    Color
  >
  _wheelColors = [
    const Color(
      0xFF4F46E5,
    ), // Blue
    const Color(
      0xFF7C3AED,
    ), // Purple
    const Color(
      0xFF4F46E5,
    ), // Blue
    const Color(
      0xFF7C3AED,
    ), // Purple
    const Color(
      0xFF4F46E5,
    ), // Blue
    const Color(
      0xFF7C3AED,
    ), // Purple
    const Color(
      0xFF4F46E5,
    ), // Blue
    const Color(
      0xFF7C3AED,
    ), // Purple
  ];

  @override
  void
  initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        seconds: 3,
      ),
      vsync: this,
    );
    _animation =
        Tween<
              double
            >(
              begin: 0,
              end: 0,
            )
            .animate(
              _controller,
            );
  }

  @override
  void
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  void
  _spinWheel() {
    if (_isSpinning ||
        _spinsLeft <=
            0)
      return;

    setState(
      () {
        _isSpinning = true;
        _spinsLeft--;
      },
    );

    // Random rotation between 5-10 full rotations plus random angle
    final double randomRotation =
        (5 +
            Random().nextDouble() *
                5) *
        2 *
        pi;
    final double finalAngle =
        randomRotation +
        Random().nextDouble() *
            2 *
            pi;

    _animation =
        Tween<
              double
            >(
              begin: 0,
              end: finalAngle,
            )
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOutCubic,
              ),
            );

    _controller.forward().then(
      (
        _,
      ) {
        setState(
          () {
            _isSpinning = false;
          },
        );
        _controller.reset();
      },
    );
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(
                0xFF8B5CF6,
              ), // Purple at top
              Color(
                0xFF3B82F6,
              ), // Blue at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and title
              Padding(
                padding: const EdgeInsets.all(
                  20,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(
                        context,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    const Text(
                      'Spin the wheel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Wheel section
              Stack(
                alignment: Alignment.center,
                children: [
                  // Wheel
                  AnimatedBuilder(
                    animation: _animation,
                    builder:
                        (
                          context,
                          child,
                        ) {
                          return Transform.rotate(
                            angle: _animation.value,
                            child: Container(
                              width: 280,
                              height: 280,
                              child: CustomPaint(
                                painter: WheelPainter(
                                  _wheelValues,
                                  _wheelColors,
                                ),
                              ),
                            ),
                          );
                        },
                  ),

                  // Center coin
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(
                        0xFFFFB800,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(
                            0,
                            4,
                          ),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  // Orange triangular pointer at top
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      child: CustomPaint(
                        painter: TrianglePointer(),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Spin button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                ),
                child: GestureDetector(
                  onTap: _spinWheel,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color:
                          _spinsLeft >
                              0
                          ? Colors.white
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(
                        28,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.1,
                          ),
                          blurRadius: 10,
                          offset: const Offset(
                            0,
                            4,
                          ),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _isSpinning
                            ? 'Spinning...'
                            : 'Spin the wheel',
                        style: TextStyle(
                          color:
                              _spinsLeft >
                                  0
                              ? Colors.black
                              : Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // Spins counter
              Text(
                '$_spinsLeft/$_totalSpins',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WheelPainter
    extends
        CustomPainter {
  final List<
    int
  >
  values;
  final List<
    Color
  >
  colors;

  WheelPainter(
    this.values,
    this.colors,
  );

  @override
  void
  paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width /
          2,
      size.height /
          2,
    );
    final radius =
        size.width /
        2;
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw outer blue ring
    paint.color = const Color(
      0xFF4A90E2,
    );
    canvas.drawCircle(
      center,
      radius,
      paint,
    );

    // Draw middle blue ring
    paint.color = const Color(
      0xFF357ABD,
    );
    canvas.drawCircle(
      center,
      radius -
          6,
      paint,
    );

    // Draw inner dark ring
    paint.color = const Color(
      0xFF1A1A2E,
    );
    canvas.drawCircle(
      center,
      radius -
          12,
      paint,
    );

    final sectionAngle =
        2 *
        pi /
        values.length;

    // Draw wheel sections
    for (
      int i = 0;
      i <
          values.length;
      i++
    ) {
      final startAngle =
          i *
              sectionAngle -
          pi /
              2;

      // Draw dark section background
      paint.color = const Color(
        0xFF1A1A2E,
      );
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius:
              radius -
              20,
        ),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Draw section divider lines
      paint.color = const Color(
        0xFF4A90E2,
      );
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;

      final lineStart = Offset(
        center.dx +
            30 *
                cos(
                  startAngle,
                ),
        center.dy +
            30 *
                sin(
                  startAngle,
                ),
      );
      final lineEnd = Offset(
        center.dx +
            (radius -
                    20) *
                cos(
                  startAngle,
                ),
        center.dy +
            (radius -
                    20) *
                sin(
                  startAngle,
                ),
      );

      canvas.drawLine(
        lineStart,
        lineEnd,
        paint,
      );
      paint.style = PaintingStyle.fill;

      // Draw text
      final textAngle =
          startAngle +
          sectionAngle /
              2;
      final textRadius =
          radius -
          50;
      final textCenter = Offset(
        center.dx +
            textRadius *
                cos(
                  textAngle,
                ),
        center.dy +
            textRadius *
                sin(
                  textAngle,
                ),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: values[i].toString(),
          style: const TextStyle(
            color: Color(
              0xFFFFB800,
            ),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          textCenter.dx -
              textPainter.width /
                  2,
          textCenter.dy -
              textPainter.height /
                  2,
        ),
      );
    }
  }

  @override
  bool
  shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) => false;
}

class TrianglePointer
    extends
        CustomPainter {
  @override
  void
  paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw blue outline
    paint.color = const Color(
      0xFF4A90E2,
    );
    final outerPath = Path();
    outerPath.moveTo(
      size.width /
          2,
      size.height -
          5,
    );
    outerPath.lineTo(
      size.width /
              2 -
          18,
      5,
    );
    outerPath.lineTo(
      size.width /
              2 +
          18,
      5,
    );
    outerPath.close();
    canvas.drawPath(
      outerPath,
      paint,
    );

    // Draw orange triangle
    paint.color = const Color(
      0xFFFF8C00,
    );
    final path = Path();
    path.moveTo(
      size.width /
          2,
      size.height -
          8,
    );
    path.lineTo(
      size.width /
              2 -
          15,
      8,
    );
    path.lineTo(
      size.width /
              2 +
          15,
      8,
    );
    path.close();
    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool
  shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) => false;
}
