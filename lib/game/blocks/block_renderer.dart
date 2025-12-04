import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'block.dart';

class BlockRenderer extends StatelessWidget {
  final Block block;
  final double cellSize;
  final double opacity;
  
  const BlockRenderer({
    super.key,
    required this.block,
    this.cellSize = GameConstants.blockSize,
    this.opacity = 1.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          block.height,
          (row) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              block.width,
              (col) => _buildCell(block.shapeMatrix[row][col], block.color),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCell(bool isFilled, int color) {
    if (!isFilled) {
      // Return empty space with same dimensions to maintain grid structure
      return SizedBox(
        width: cellSize,
        height: cellSize,
      );
    }
    
    final baseColor = Color(color);
    // Create balanced gradient colors - lighter than before
    final lightColor = Color.lerp(baseColor, Colors.white, 0.25) ?? baseColor;
    final darkColor = Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor;
    
    return Container(
      width: cellSize,
      height: cellSize,
      margin: const EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        // Gradient for 3D effect
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lightColor,
            baseColor,
            darkColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.zero, // Square corners to match grid
        // Outer border - bright highlight
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          // Inner highlight (top-left)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 0,
            offset: const Offset(-1.5, -1.5),
            spreadRadius: 0,
          ),
          // Main shadow (bottom-right) - deeper and more defined
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(4, 4),
            spreadRadius: 0,
          ),
          // Outer glow
          BoxShadow(
            color: baseColor.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(2, 2),
            spreadRadius: 1,
          ),
          // Inner shadow for depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(1, 1),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Shine effect overlay
          Positioned(
            top: -cellSize * 0.3,
            left: -cellSize * 0.3,
            child: Container(
              width: cellSize * 0.6,
              height: cellSize * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Subtle inner border for definition
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.zero, // Square corners
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

