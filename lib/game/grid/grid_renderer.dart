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

class _GridRendererState extends State<GridRenderer> {
  final List<_FallingParticleData> _fallingParticles = [];
  
  @override
  void didUpdateWidget(GridRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if there are cells marked for clearing (for particles)
    List<_CellClearData> cellsToClear = [];
    
    for (int row = 0; row < widget.grid.rows; row++) {
      for (int col = 0; col < widget.grid.cols; col++) {
        final cell = widget.grid.getCell(row, col);
        if (cell?.isClearing ?? false) {
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
    // Check if there are cells marked for clearing (for particles)
    List<_CellClearData> cellsToClear = [];
    
    for (int row = 0; row < widget.grid.rows; row++) {
      for (int col = 0; col < widget.grid.cols; col++) {
        final cell = widget.grid.getCell(row, col);
        if (cell?.isClearing ?? false) {
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
    
    // Cells are cleared immediately, no animation needed
    
    // Calculate grid dimensions - use const values where possible to prevent jitter
    const cellMargin = 0.5;
    final cellSpacing = widget.cellSize + (cellMargin * 2);
    final gridWidth = widget.grid.cols * cellSpacing;
    final gridHeight = widget.grid.rows * cellSpacing;
    const borderWidth = 3.0;
    final totalWidth = gridWidth + (borderWidth * 2);
    final totalHeight = gridHeight + (borderWidth * 2);
    
    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background container with border - fixed size to prevent jitter
          Container(
            width: totalWidth,
            height: totalHeight,
            decoration: BoxDecoration(
            // Professional wood-themed gradient background
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(GameConstants.gridBackgroundColor),
                const Color(0xFF7A5A3A), // Slightly darker wood
                const Color(GameConstants.gridBackgroundColor),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.zero, // Square corners to match grid cells
            // Professional wood border with shadow
            border: Border.all(
              color: const Color(GameConstants.gridBorderColor),
              width: borderWidth,
            ),
            boxShadow: [
              // Inner shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 0,
                offset: const Offset(2, 2),
                spreadRadius: 0,
              ),
              // Outer shadow for elevation
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
        ),
        // Grid content positioned to align with border inner edge
        Positioned(
          left: borderWidth,
          top: borderWidth,
          child: Stack(
            children: [
              // Grid lines overlay for professional look
              CustomPaint(
                size: Size(
                  widget.grid.cols * (widget.cellSize + 1),
                  widget.grid.rows * (widget.cellSize + 1),
                ),
                painter: _GridLinesPainter(
                  rows: widget.grid.rows,
                  cols: widget.grid.cols,
                  cellSize: widget.cellSize,
                ),
              ),
              // Cells - start immediately at border inner edge
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.grid.rows,
                  (row) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.grid.cols,
                      (col) {
                        final cell = widget.grid.getCell(row, col);
                        return cell != null ? _buildCell(cell, row: row, col: col) : const SizedBox();
                      },
                    ),
                  ),
                ),
              ),
            ],
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
      ),
    );
  }
  
  Widget _buildCell(GridCell cell, {int? row, int? col}) {
    final isFilled = cell.isFilled;
    final cellColor = cell.color;
    
    // Determine if this is an edge cell (no margin on outer edges)
    final isTopEdge = row == 0;
    final isBottomEdge = row == widget.grid.rows - 1;
    final isLeftEdge = col == 0;
    final isRightEdge = col == widget.grid.cols - 1;
    
    // Normal cell display with enhanced graphics
    if (isFilled && cellColor != 0) {
      final baseColor = Color(cellColor);
      final lightColor = Color.lerp(baseColor, Colors.white, 0.25) ?? baseColor;
      final darkColor = Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor;
      
      return Container(
        width: widget.cellSize,
        height: widget.cellSize,
        // Remove margin on outer edges to make border sát với grid
        margin: EdgeInsets.only(
          top: isTopEdge ? 0 : 0.5,
          bottom: isBottomEdge ? 0 : 0.5,
          left: isLeftEdge ? 0 : 0.5,
          right: isRightEdge ? 0 : 0.5,
        ),
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
    
    // Empty cell - Professional wood-themed design
    return Container(
      width: widget.cellSize,
      height: widget.cellSize,
      // Remove margin on outer edges to make border sát với grid
      margin: EdgeInsets.only(
        top: isTopEdge ? 0 : 0.5,
        bottom: isBottomEdge ? 0 : 0.5,
        left: isLeftEdge ? 0 : 0.5,
        right: isRightEdge ? 0 : 0.5,
      ),
      decoration: BoxDecoration(
        // Subtle wood grain effect for empty cells
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(GameConstants.emptyCellColor),
            const Color(0xFF5A3E28), // Slightly darker
            const Color(GameConstants.emptyCellColor),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: const Color(GameConstants.gridLineColor).withValues(alpha: 0.25),
          width: 1,
        ),
        // Subtle inner shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(1, 1),
            spreadRadius: -1,
          ),
        ],
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

// Professional grid lines painter
class _GridLinesPainter extends CustomPainter {
  final int rows;
  final int cols;
  final double cellSize;
  
  _GridLinesPainter({
    required this.rows,
    required this.cols,
    required this.cellSize,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(GameConstants.gridLineColor).withValues(alpha: 0.2);
    
    // Draw vertical lines
    for (int col = 0; col <= cols; col++) {
      final x = col * (cellSize + 1) + 0.5;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (int row = 0; row <= rows; row++) {
      final y = row * (cellSize + 1) + 0.5;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

