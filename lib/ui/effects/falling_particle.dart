import 'package:flutter/material.dart';
import 'dart:math';

class FallingParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double opacity;
  double rotation;
  double rotationSpeed;
  
  FallingParticle({
    required this.position,
    required this.velocity,
    required this.color,
    this.size = 4.0,
    this.opacity = 1.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
  });
  
  void update(double deltaTime) {
    // Apply gravity
    velocity = Offset(velocity.dx, velocity.dy + 300 * deltaTime);
    
    // Update position
    position = Offset(
      position.dx + velocity.dx * deltaTime,
      position.dy + velocity.dy * deltaTime,
    );
    
    // Update rotation
    rotation += rotationSpeed * deltaTime;
    
    // Fade out over time
    opacity = (opacity - 0.5 * deltaTime).clamp(0.0, 1.0);
  }
  
  bool isAlive() {
    return opacity > 0.0;
  }
}

class FallingParticleEffect extends StatefulWidget {
  final Offset startPosition;
  final Color color;
  final int particleCount;
  final VoidCallback? onComplete;
  
  const FallingParticleEffect({
    super.key,
    required this.startPosition,
    required this.color,
    this.particleCount = 15,
    this.onComplete,
  });
  
  @override
  State<FallingParticleEffect> createState() => _FallingParticleEffectState();
}

class _FallingParticleEffectState extends State<FallingParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FallingParticle> _particles = [];
  final Random _random = Random();
  DateTime? _lastUpdateTime;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Create particles
    for (int i = 0; i < widget.particleCount; i++) {
      final angle = (_random.nextDouble() * 2 * pi) - pi; // Random angle
      final speed = 50 + _random.nextDouble() * 100; // Random speed
      final horizontalSpread = (_random.nextDouble() - 0.5) * 60; // Horizontal spread
      
      _particles.add(FallingParticle(
        position: Offset(
          widget.startPosition.dx + horizontalSpread,
          widget.startPosition.dy,
        ),
        velocity: Offset(
          cos(angle) * speed,
          sin(angle) * speed - 50, // Initial upward velocity
        ),
        color: widget.color,
        size: 3 + _random.nextDouble() * 4,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      ));
    }
    
    _lastUpdateTime = DateTime.now();
    _controller.addListener(_updateParticles);
    _controller.forward().then((_) {
      if (mounted && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }
  
  void _updateParticles() {
    if (!mounted) return;
    
    final now = DateTime.now();
    final deltaTime = _lastUpdateTime != null 
        ? now.difference(_lastUpdateTime!).inMilliseconds / 1000.0
        : 0.016; // Default to ~60fps
    _lastUpdateTime = now;
    
    setState(() {
      for (var particle in _particles) {
        particle.update(deltaTime);
      }
      
      // Remove dead particles
      _particles.removeWhere((p) => !p.isAlive());
      
      // If all particles are dead, complete animation
      if (_particles.isEmpty && _controller.isCompleted) {
        _controller.stop();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 300,
      child: CustomPaint(
        painter: _FallingParticlePainter(_particles),
        size: const Size(200, 300),
      ),
    );
  }
}

class _FallingParticlePainter extends CustomPainter {
  final List<FallingParticle> particles;
  
  _FallingParticlePainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);
      
      // Draw particle as a small rectangle
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size,
        ),
        paint,
      );
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

