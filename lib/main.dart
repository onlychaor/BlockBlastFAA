import 'package:flutter/material.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'ui/play_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Block Blast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlameSplashScreen(
      theme: FlameSplashTheme.dark,
      onFinish: (context) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PlayScreen()),
        );
      },
      showAfter: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.grey.shade900,
                Colors.black,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main title with enhanced styling
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect behind text
                    Text(
                      'BLOCK BLAST',
                      style: GoogleFonts.fredoka(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4
                          ..color = Colors.yellow.shade400,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.3, 0.3), end: const Offset(1, 1)),
                    // Main text
                    Text(
                      'BLOCK BLAST',
                      style: GoogleFonts.fredoka(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 0),
                            blurRadius: 20,
                            color: Colors.yellow.shade400.withOpacity(0.8),
                          ),
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1))
                        .then()
                        .shimmer(
                          duration: 2500.ms,
                          color: Colors.yellow.withOpacity(0.5),
                        ),
                  ],
                ),
                const SizedBox(height: 20),
                // Decorative yellow lines
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.yellow.shade400,
                            Colors.yellow.shade400,
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.shade400.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 800.ms)
                        .scaleX(begin: 0, end: 1),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.yellow.shade300,
                            Colors.yellow.shade300,
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 1000.ms)
                        .scaleX(begin: 0, end: 1),
                  ],
                ),
                const SizedBox(height: 60),
                // Animated loading indicator
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.yellow.shade400,
                            width: 3,
                          ),
                        ),
                        child: CustomPaint(
                          painter: _LoadingArcPainter(),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 1200.ms)
                        .scale(begin: const Offset(0, 0), end: const Offset(1, 1));
                  },
                ),
                const SizedBox(height: 20),
                // Loading text
                Text(
                  'Loading...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 2,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 1400.ms)
                    .then()
                    .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.3)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoadingArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - 2,
    );

    canvas.drawArc(
      rect,
      -1.57, // Start at top (-90 degrees)
      2.5, // Draw 3/4 of the circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

