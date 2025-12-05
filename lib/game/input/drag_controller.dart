import 'package:flutter/material.dart';
import '../blocks/block.dart';
import '../grid/grid.dart';
import '../../utils/constants.dart';

class DragController {
  Block? _draggedBlock;
  Offset? _dragPosition;
  int? _gridRow;
  int? _gridCol;
  
  Block? get draggedBlock => _draggedBlock;
  Offset? get dragPosition => _dragPosition;
  int? get gridRow => _gridRow;
  int? get gridCol => _gridCol;
  
  bool get isDragging => _draggedBlock != null;
  
  /// Start dragging a block
  void startDrag(Block block, Offset globalPosition) {
    // Create a copy of the block to ensure we use the current state
    _draggedBlock = block.copy();
    _dragPosition = globalPosition;
  }
  
  /// Update drag position (grid local position)
  void updateDrag(Offset gridLocalPosition) {
    if (_draggedBlock == null) return;
    _dragPosition = gridLocalPosition;
    _updateGridPosition(gridLocalPosition);
  }
  
  /// Update grid position based on pixel position relative to grid
  void _updateGridPosition(Offset gridPosition) {
    if (_draggedBlock == null) return;
    
    // Account for grid border (3px) and padding (1.0px) = 4px total
    const borderWidth = 3.0;
    const gridPadding = 1.0;
    final totalOffset = borderWidth + gridPadding;
    final adjustedX = gridPosition.dx - totalOffset;
    final adjustedY = gridPosition.dy - totalOffset;
    
    // Account for cell margin (0.5px each side = 1px total spacing)
    const cellMargin = 0.5;
    final cellSpacing = GameConstants.cellSize + (cellMargin * 2); // cellSize + 1px
    
    // Calculate max valid positions for block placement
    final maxRow = GameConstants.gridRows - _draggedBlock!.height;
    final maxCol = GameConstants.gridCols - _draggedBlock!.width;
    
    // Allow larger margin outside grid for better edge placement, especially for top edge
    final margin = GameConstants.cellSize * 0.5;
    final gridWidth = GameConstants.gridCols * cellSpacing;
    final gridHeight = GameConstants.gridRows * cellSpacing;
    
    // Check if position is completely outside grid (with larger margin for top)
    // Allow more margin at top to make it easier to place blocks at top edge
    if (adjustedX < -margin || adjustedY < -margin * 2 ||
        adjustedX > gridWidth + margin ||
        adjustedY > gridHeight + margin) {
      _gridRow = null;
      _gridCol = null;
      return;
    }
    
    // Calculate which grid cell the position is in
    // Use cellSpacing to account for margin
    final cellRow = adjustedY / cellSpacing;
    final cellCol = adjustedX / cellSpacing;
    
    // For blocks with height=1 (horizontal blocks like 1x4), use simpler calculation
    // Calculate top-left corner position for the block
    if (_draggedBlock!.height == 1) {
      // For horizontal blocks, use the row directly (no center adjustment needed)
      _gridRow = cellRow.floor();
      _gridCol = (cellCol - (_draggedBlock!.width / 2)).floor();
    } else {
      // For other blocks, use center-based calculation with optimized rounding
      // Use round for smoother, more natural snapping
      final topLeftRow = cellRow - (_draggedBlock!.height / 2);
      final topLeftCol = cellCol - (_draggedBlock!.width / 2);
      _gridRow = topLeftRow.round();
      _gridCol = topLeftCol.round();
    }
    
    // Clamp to valid grid bounds (allow placement at all edges including corners)
    // This ensures blocks can be placed at:
    // - Top-left corner: (0, 0) - especially important for 1x4 blocks
    // - Top-right corner: (0, maxCol)
    // - Bottom-left corner: (maxRow, 0)
    // - Bottom-right corner: (maxRow, maxCol)
    // - All edges
    if (_gridRow! < 0) {
      _gridRow = 0;
    } else if (_gridRow! > maxRow) {
      _gridRow = maxRow;
    }
    
    if (_gridCol! < 0) {
      _gridCol = 0;
    } else if (_gridCol! > maxCol) {
      _gridCol = maxCol;
    }
    
    // Final validation - ensure position is valid
    // At this point, position should always be valid if we got here
    if (_gridRow! < 0 || _gridCol! < 0 ||
        _gridRow! > maxRow || _gridCol! > maxCol) {
      _gridRow = null;
      _gridCol = null;
    }
  }
  
  /// End drag and return the block
  Block? endDrag() {
    final block = _draggedBlock;
    _draggedBlock = null;
    _dragPosition = null;
    _gridRow = null;
    _gridCol = null;
    return block;
  }
  
  /// Cancel drag
  void cancelDrag() {
    _draggedBlock = null;
    _dragPosition = null;
    _gridRow = null;
    _gridCol = null;
  }
  
  /// Check if block can be placed at current grid position
  bool canPlaceAt(int maxRows, int maxCols) {
    if (_draggedBlock == null || _gridRow == null || _gridCol == null) {
      return false;
    }
    
    // Check if block fits within grid bounds
    if (_gridRow! < 0 || 
        _gridCol! < 0 || 
        _gridRow! + _draggedBlock!.height > maxRows ||
        _gridCol! + _draggedBlock!.width > maxCols) {
      return false;
    }
    
    return true;
  }
  
  /// Check if block can be placed on grid (including checking empty cells)
  bool canPlaceOnGrid(Grid grid) {
    if (!canPlaceAt(grid.rows, grid.cols)) {
      return false;
    }
    
    if (_draggedBlock == null || _gridRow == null || _gridCol == null) {
      return false;
    }
    
    return grid.canPlaceBlock(
      _draggedBlock!.shapeMatrix,
      _gridRow!,
      _gridCol!,
    );
  }
  
  /// Rotate the dragged block
  void rotateDraggedBlock() {
    if (_draggedBlock != null) {
      _draggedBlock = _draggedBlock!.rotate();
      // Recalculate grid position after rotation since block dimensions changed
      if (_dragPosition != null) {
        _updateGridPosition(_dragPosition!);
      }
    }
  }
}

