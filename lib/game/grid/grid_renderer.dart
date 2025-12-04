import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'grid.dart';
import 'grid_cell.dart';
import '../../ui/effects/falling_particle.dart';

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
  final List<_FallingParticleData> _fallingParticles = [];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: GameConstants.lineClearAnimation,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
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
    List<_CellClearData> cellsToClear = [];
    
    for (int row = 0; row < widget.grid.rows; row++) {
      for (int col = 0; col < widget.grid.cols; col++) {
        final cell = widget.grid.getCell(row, col);
        if (cell?.isClearing ?? false) {
          hasClearingCells = true;
          // Check if this cell was not clearing before (newly marked)
          final wasClearing = oldWidget.grid.getCell(row, col)?.isClearing ?? false;
          if (!wasClearing && cell?.isFilled == true && cell?.color != 0) {
            cellsToClear.add(_CellClearData(
              row: row,
              col: col,
              color: cell!.color,
            ));
          }
        }
      }
    }
    
    // Create falling particles for newly cleared cells - trigger immediately
    if (cellsToClear.isNotEmpty) {
      // Use a small delay to ensure grid is rendered first
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _createFallingParticles(cellsToClear);
        }
      });
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
  
  void _createFallingParticles(List<_CellClearData> cells) {
    const cellMargin = 0.5;
    final cellSpacing = widget.cellSize + (cellMargin * 2);
    const gridPadding = 0.5; // Match container padding
    
    for (var cellData in cells) {
      // Calculate cell center position (local to grid container)
      final cellX = (cellData.col * cellSpacing) + gridPadding + (widget.cellSize / 2);
      final cellY = (cellData.row * cellSpacing) + gridPadding + (widget.cellSize / 2);
      
      final position = Offset(cellX, cellY);
      
      setState(() {
        _fallingParticles.add(_FallingParticleData(
          position: position,
          color: Color(cellData.color),
          onComplete: () {
            setState(() {
              _fallingParticles.removeWhere((p) => 
                (p.position.dx - position.dx).abs() < 1 && 
                (p.position.dy - position.dy).abs() < 1
              );
            });
          },
        ));
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Check if there are cells marked for clearing
    bool hasClearingCells = false;
    List<_CellClearData> cellsToClear = [];
    
    for (int row = 0; row < widget.grid.rows; row++) {
      for (int col = 0; col < widget.grid.cols; col++) {
        final cell = widget.grid.getCell(row, col);
        if (cell?.isClearing ?? false) {
          hasClearingCells = true;
          // Create particles for cells being cleared
          if (cell?.isFilled == true && cell?.color != 0) {
            // Check if we haven't already created particles for this cell
            final alreadyHasParticle = _fallingParticles.any((p) {
            const cellMargin = 0.5;
            final cellSpacing = widget.cellSize + (cellMargin * 2);
            const gridPadding = 0.5; // Match container padding
            final cellX = (col * cellSpacing) + gridPadding + (widget.cellSize / 2);
            final cellY = (row * cellSpacing) + gridPadding + (widget.cellSize / 2);
              return (p.position.dx - cellX).abs() < 5 && (p.position.dy - cellY).abs() < 5;
            });
            
            if (!alreadyHasParticle) {
              cellsToClear.add(_CellClearData(
                row: row,
                col: col,
                color: cell!.color,
              ));
            }
          }
        }
      }
    }
    
    // Create falling particles for cells being cleared
    if (cellsToClear.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _createFallingParticles(cellsToClear);
        }
      });
    }
    
    // Trigger animation when cells are marked for clearing
    if (hasClearingCells && !_animationController.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          triggerClearAnimation();
        }
      });
    }
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          // Padding matches cell margin (0.5) to align grid perfectly with border
          padding: const EdgeInsets.all(0.5),
          decoration: BoxDecoration(
            color: const Color(GameConstants.gridBackgroundColor),
            borderRadius: BorderRadius.zero, // Square corners to match grid cells
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
        ),
        // Falling particles overlay
        ..._fallingParticles.map((particleData) {
          return Positioned(
            left: particleData.position.dx - 100,
            top: particleData.position.dy,
            child: IgnorePointer(
              child: FallingParticleEffect(
                startPosition: const Offset(100, 0),
                color: particleData.color,
                particleCount: 15,
                onComplete: particleData.onComplete,
              ),
            ),
          );
        }),
      ],
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
                  // Reduced glow effect for less visual noise
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 4 * _scaleAnimation.value,
                      spreadRadius: 1 * _scaleAnimation.value,
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
      final darkColor = Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor;
      
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

// Helper class to track cell clear data
class _CellClearData {
  final int row;
  final int col;
  final int color;
  
  _CellClearData({
    required this.row,
    required this.col,
    required this.color,
  });
}

// Helper class to track falling particle data
class _FallingParticleData {
  final Offset position;
  final Color color;
  final VoidCallback onComplete;
  
  _FallingParticleData({
    required this.position,
    required this.color,
    required this.onComplete,
  });
}

