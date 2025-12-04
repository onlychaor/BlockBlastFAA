import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'grid.dart';
import 'grid_cell.dart';

class GridRenderer extends StatefulWidget {
  final Grid grid;
  final double cellSize;
  
  const GridRenderer({
    super.key,
    required this.grid,
    this.cellSize = GameConstants.cellSize,
  });
  
  @override
  State<GridRenderer> createState() => _GridRendererState();
}

class _GridRendererState extends State<GridRenderer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: GameConstants.lineClearAnimation,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void triggerClearAnimation() {
    _animationController.forward(from: 0.0);
  }
  
  @override
  void didUpdateWidget(GridRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if there are cells marked for clearing
    bool hasClearingCells = false;
    for (int row = 0; row < widget.grid.rows; row++) {
      for (int col = 0; col < widget.grid.cols; col++) {
        if (widget.grid.getCell(row, col)?.isClearing ?? false) {
          hasClearingCells = true;
          break;
        }
      }
      if (hasClearingCells) break;
    }
    
    // Trigger animation when cells are marked for clearing
    if (hasClearingCells && !_animationController.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          triggerClearAnimation();
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Check if there are cells marked for clearing
    bool hasClearingCells = false;
    for (int row = 0; row < widget.grid.rows; row++) {
      for (int col = 0; col < widget.grid.cols; col++) {
        if (widget.grid.getCell(row, col)?.isClearing ?? false) {
          hasClearingCells = true;
          break;
        }
      }
      if (hasClearingCells) break;
    }
    
    // Trigger animation when cells are marked for clearing
    if (hasClearingCells && !_animationController.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          triggerClearAnimation();
        }
      });
    }
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(GameConstants.gridBackgroundColor),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(GameConstants.gridLineColor).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.grid.rows,
          (row) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              widget.grid.cols,
              (col) {
                final cell = widget.grid.getCell(row, col);
                return cell != null ? _buildCell(cell) : const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCell(GridCell cell) {
    final isFilled = cell.isFilled;
    final isClearing = cell.isClearing;
    final cellColor = cell.color;
    
    // If cell is being cleared, show animation
    if (isClearing && isFilled && cellColor != 0) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: widget.cellSize,
                height: widget.cellSize,
                decoration: BoxDecoration(
                  color: Color(cellColor),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 8 * _scaleAnimation.value,
                      spreadRadius: 2 * _scaleAnimation.value,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    
    // Normal cell display with enhanced graphics
    if (isFilled && cellColor != 0) {
      final baseColor = Color(cellColor);
      final lightColor = Color.lerp(baseColor, Colors.white, 0.25) ?? baseColor;
      final darkColor = Color.lerp(baseColor, Colors.black, 0.2) ?? baseColor;
      
      return Container(
        width: widget.cellSize,
        height: widget.cellSize,
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
          borderRadius: BorderRadius.zero, // Square corners
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
              top: -widget.cellSize * 0.3,
              left: -widget.cellSize * 0.3,
              child: Container(
                width: widget.cellSize * 0.6,
                height: widget.cellSize * 0.6,
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
    
    // Empty cell - must have same margin as filled cells
    return Container(
      width: widget.cellSize,
      height: widget.cellSize,
      margin: const EdgeInsets.all(0.5), // Same margin as filled cells
      decoration: BoxDecoration(
        color: const Color(GameConstants.emptyCellColor),
        border: Border.all(
          color: const Color(GameConstants.gridLineColor).withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
    );
  }
}

