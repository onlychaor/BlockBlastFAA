import 'dart:math';
import '../../utils/constants.dart';
import 'grid_cell.dart';

class Grid {
  final int rows;
  final int cols;
  late List<List<GridCell>> _cells;
  
  Grid({int? rows, int? cols})
      : rows = rows ?? GameConstants.gridRows,
        cols = cols ?? GameConstants.gridCols {
    _initializeGrid();
  }
  
  void _initializeGrid() {
    _cells = List.generate(
      rows,
      (row) => List.generate(
        cols,
        (col) => GridCell(row: row, col: col),
      ),
    );
  }
  
  /// Get cell at position
  GridCell? getCell(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) {
      return null;
    }
    return _cells[row][col];
  }
  
  /// Check if position is valid and empty
  bool canPlaceAt(int row, int col) {
    final cell = getCell(row, col);
    return cell != null && cell.isEmpty;
  }
  
  /// Fill cell at position
  bool fillCell(int row, int col, int color) {
    final cell = getCell(row, col);
    if (cell != null && cell.isEmpty) {
      cell.fill(color);
      return true;
    }
    return false;
  }
  
  /// Clear cell at position
  void clearCell(int row, int col) {
    final cell = getCell(row, col);
    cell?.clear();
  }
  
  /// Check if a row is full
  bool isRowFull(int row) {
    for (int col = 0; col < cols; col++) {
      if (getCell(row, col)?.isEmpty ?? true) {
        return false;
      }
    }
    return true;
  }
  
  /// Check if a column is full
  bool isColFull(int col) {
    for (int row = 0; row < rows; row++) {
      if (getCell(row, col)?.isEmpty ?? true) {
        return false;
      }
    }
    return true;
  }
  
  /// Get all full rows
  List<int> getFullRows() {
    List<int> fullRows = [];
    for (int row = 0; row < rows; row++) {
      if (isRowFull(row)) {
        fullRows.add(row);
      }
    }
    return fullRows;
  }
  
  /// Get all full columns
  List<int> getFullCols() {
    List<int> fullCols = [];
    for (int col = 0; col < cols; col++) {
      if (isColFull(col)) {
        fullCols.add(col);
      }
    }
    return fullCols;
  }
  
  /// Mark full rows and columns for clearing (for animation)
  int markFullLinesForClearing() {
    final fullRows = getFullRows();
    final fullCols = getFullCols();
    
    // Mark full rows
    for (int row in fullRows) {
      for (int col = 0; col < cols; col++) {
        getCell(row, col)?.markForClearing();
      }
    }
    
    // Mark full columns
    for (int col in fullCols) {
      for (int row = 0; row < rows; row++) {
        getCell(row, col)?.markForClearing();
      }
    }
    
    return fullRows.length + fullCols.length;
  }
  
  /// Clear full rows and columns
  int clearFullLines() {
    final fullRows = getFullRows();
    final fullCols = getFullCols();
    
    // Clear full rows
    for (int row in fullRows) {
      for (int col = 0; col < cols; col++) {
        clearCell(row, col);
      }
    }
    
    // Clear full columns
    for (int col in fullCols) {
      for (int row = 0; row < rows; row++) {
        clearCell(row, col);
      }
    }
    
    return fullRows.length + fullCols.length;
  }
  
  /// Check if block can be placed at position
  bool canPlaceBlock(List<List<bool>> shape, int startRow, int startCol) {
    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j]) {
          final row = startRow + i;
          final col = startCol + j;
          if (!canPlaceAt(row, col)) {
            return false;
          }
        }
      }
    }
    return true;
  }
  
  /// Place block on grid
  bool placeBlock(List<List<bool>> shape, int startRow, int startCol, int color) {
    if (!canPlaceBlock(shape, startRow, startCol)) {
      return false;
    }
    
    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j]) {
          fillCell(startRow + i, startCol + j, color);
        }
      }
    }
    return true;
  }
  
  /// Reset grid
  void reset() {
    _initializeGrid();
  }
  
  /// Initialize grid with random blocks (for starting game with pre-filled blocks)
  void initializeWithRandomBlocks({int numBlocks = 8}) {
    _initializeGrid();
    final random = Random();
    final simpleShapes = [
      [[true]], // Single block
      [[true, true]], // 2x1 horizontal
      [[true], [true]], // 1x2 vertical
      [[true, true], [true, false]], // Small L
      [[true, true], [false, true]], // Small reverse L
    ];
    
    int attempts = 0;
    int placedBlocks = 0;
    const maxAttempts = 200;
    
    while (placedBlocks < numBlocks && attempts < maxAttempts) {
      attempts++;
      
      // Pick a random simple shape
      final shape = simpleShapes[random.nextInt(simpleShapes.length)];
      final color = GameConstants.blockColors[random.nextInt(GameConstants.blockColors.length)];
      
      // Try to find a valid position
      final maxRow = rows - shape.length;
      final maxCol = cols - (shape.isNotEmpty ? shape[0].length : 0);
      
      if (maxRow < 0 || maxCol < 0) continue;
      
      // Try random positions
      for (int tryCount = 0; tryCount < 15; tryCount++) {
        final row = random.nextInt(maxRow + 1);
        final col = random.nextInt(maxCol + 1);
        
        // Check if we can place this block
        if (canPlaceBlock(shape, row, col)) {
          // Place the block temporarily
          placeBlock(shape, row, col, color);
          
          // Check if this placement creates a full line
          final fullRows = getFullRows();
          final fullCols = getFullCols();
          
          // If it creates a full line, undo and try again
          if (fullRows.isNotEmpty || fullCols.isNotEmpty) {
            // Undo placement
            for (int i = 0; i < shape.length; i++) {
              for (int j = 0; j < shape[i].length; j++) {
                if (shape[i][j]) {
                  clearCell(row + i, col + j);
                }
              }
            }
            continue;
          }
          
          placedBlocks++;
          break;
        }
      }
    }
  }
  
  /// Get all cells (for rendering)
  List<List<GridCell>> get cells => _cells;
}

