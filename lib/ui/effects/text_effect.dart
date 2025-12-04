import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextEffect extends StatefulWidget {
  final String text;
  final Color color;
  final Offset position;
  final double fontSize;
  final VoidCallback? onComplete;
  
  const TextEffect({
    super.key,
    required this.text,
    required this.color,
    required this.position,
    required this.fontSize,
    this.onComplete,
  });
  
  @override
  State<TextEffect> createState() => _TextEffectState();
}

class _TextEffectState extends State<TextEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _offsetAnimation = Tween<double>(begin: 0.0, end: -50.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _offsetAnimation.value),
              child: Text(
                widget.text,
                style: GoogleFonts.fredoka(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.5),
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

