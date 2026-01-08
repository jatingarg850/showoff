import 'dart:math';
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'ad_selection_screen.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isSpinning = false;
  int _spinsLeft = 1; // Changed to 1 since API allows once per day
  final int _totalSpins = 1;

  final List<int> _wheelValues = [50, 5, 50, 5, 10, 5, 20, 10];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _checkSpinStatus();
  }

  Future<void> _checkSpinStatus() async {
    try {
      final response = await ApiService.getSpinWheelStatus();
      if (response['success']) {
        setState(() {
          _spinsLeft = response['data']['spinsRemaining'] ?? 0;
        });
      }
    } catch (e) {
      print('Error checking spin status: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() async {
    if (_isSpinning || _spinsLeft <= 0) {
      if (_spinsLeft <= 0) {
        _showOutOfSpinsModal();
      }
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    try {
      // Call API to spin wheel
      final response = await ApiService.spinWheel();

      if (!response['success']) {
        setState(() {
          _isSpinning = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to spin wheel'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final int coinsWon = response['data']['coinsWon'];

      setState(() {
        _spinsLeft = 0; // Used the daily spin
      });

      // Random rotation between 5-10 full rotations plus random angle
      final double randomRotation = (5 + Random().nextDouble() * 5) * 2 * pi;
      final double finalAngle = randomRotation + Random().nextDouble() * 2 * pi;

      _animation = Tween<double>(begin: 0, end: finalAngle).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      _controller.forward().then((_) {
        setState(() {
          _isSpinning = false;
        });

        _controller.reset();

        // Show result modal after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          _showResultModal(coinsWon);
        });
      });
    } catch (e) {
      setState(() {
        _isSpinning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showResultModal(int wonAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Happy emoji with coin background
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB800),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('😊', style: TextStyle(fontSize: 50)),
                  ),
                ),

                const SizedBox(height: 32),

                // Congratulations message
                Text(
                  'Congratulations! You won $wonAmount coins',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Claim button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Handle claim reward
                      if (_spinsLeft <= 0) {
                        // Show out of spins modal if no spins left
                        Future.delayed(const Duration(milliseconds: 300), () {
                          _showOutOfSpinsModal();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Claim',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOutOfSpinsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sad emoji with coin background
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB800),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('😢', style: TextStyle(fontSize: 50)),
                  ),
                ),

                const SizedBox(height: 32),

                // Message
                const Text(
                  'Please visit tomorrow for more spins',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // 900 coins button
                
                const SizedBox(height: 16),

                // Watch ads button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      // Navigate to ad selection screen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdSelectionScreen(),
                        ),
                      );
                      // If user watched ads successfully, refresh spins
                      if (result == true && mounted) {
                        setState(() {
                          _spinsLeft = 5; // Reset spins after watching ads
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_outline, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Watch ads',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B5CF6), // Purple at top
              Color(0xFF3B82F6), // Blue at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animation.value,
                        child: SizedBox(
                          width: 280,
                          height: 280,
                          child: CustomPaint(
                            painter: WheelPainter(_wheelValues),
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
                      color: Color(0xFFFFB800),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.star, color: Colors.white, size: 30),
                    ),
                  ),

                  // Orange triangular pointer at top
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CustomPaint(painter: TrianglePointer()),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Spin button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: _spinWheel,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _spinsLeft > 0 ? Colors.white : Colors.grey[400],
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _isSpinning ? 'Spinning...' : 'Spin the wheel',
                        style: TextStyle(
                          color: _spinsLeft > 0
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

              const SizedBox(height: 20),

              // Spins counter
              Text(
                '$_spinsLeft/$_totalSpins',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<int> values;

  WheelPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw outer blue ring
    paint.color = const Color(0xFF4A90E2);
    canvas.drawCircle(center, radius, paint);

    // Draw middle blue ring
    paint.color = const Color(0xFF357ABD);
    canvas.drawCircle(center, radius - 6, paint);

    // Draw inner dark ring
    paint.color = const Color(0xFF1A1A2E);
    canvas.drawCircle(center, radius - 12, paint);

    final sectionAngle = 2 * pi / values.length;

    // Draw wheel sections
    for (int i = 0; i < values.length; i++) {
      final startAngle = i * sectionAngle - pi / 2;

      // Draw dark section background
      paint.color = const Color(0xFF1A1A2E);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 20),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Draw section divider lines
      paint.color = const Color(0xFF4A90E2);
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;

      final lineStart = Offset(
        center.dx + 30 * cos(startAngle),
        center.dy + 30 * sin(startAngle),
      );
      final lineEnd = Offset(
        center.dx + (radius - 20) * cos(startAngle),
        center.dy + (radius - 20) * sin(startAngle),
      );

      canvas.drawLine(lineStart, lineEnd, paint);
      paint.style = PaintingStyle.fill;

      // Draw text
      final textAngle = startAngle + sectionAngle / 2;
      final textRadius = radius - 50;
      final textCenter = Offset(
        center.dx + textRadius * cos(textAngle),
        center.dy + textRadius * sin(textAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: values[i].toString(),
          style: const TextStyle(
            color: Color(0xFFFFB800),
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
          textCenter.dx - textPainter.width / 2,
          textCenter.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrianglePointer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw blue outline
    paint.color = const Color(0xFF4A90E2);
    final outerPath = Path();
    outerPath.moveTo(size.width / 2, size.height - 5);
    outerPath.lineTo(size.width / 2 - 18, 5);
    outerPath.lineTo(size.width / 2 + 18, 5);
    outerPath.close();
    canvas.drawPath(outerPath, paint);

    // Draw orange triangle
    paint.color = const Color(0xFFFF8C00);
    final path = Path();
    path.moveTo(size.width / 2, size.height - 8);
    path.lineTo(size.width / 2 - 15, 8);
    path.lineTo(size.width / 2 + 15, 8);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
