import 'dart:math';

class BlockShapes {
  // Single block
  static const single = [
    [true]
  ];
  
  // 2x1 horizontal
  static const horizontal2 = [
    [true, true]
  ];
  
  // 3x1 horizontal
  static const horizontal3 = [
    [true, true, true]
  ];
  
  // 1x2 vertical
  static const vertical2 = [
    [true],
    [true]
  ];
  
  // 1x3 vertical
  static const vertical3 = [
    [true],
    [true],
    [true]
  ];
  
  // 2x2 square
  static const square2x2 = [
    [true, true],
    [true, true]
  ];
  
  // L shape
  static const lShape = [
    [true, false],
    [true, false],
    [true, true]
  ];
  
  // Reverse L shape
  static const reverseLShape = [
    [false, true],
    [false, true],
    [true, true]
  ];
  
  // L shape extended (4 cells: 3 vertical + 1 horizontal at bottom right)
  static const lShapeExtended = [
    [true, false],
    [true, false],
    [true, false],
    [true, true]
  ];
  
  // Reverse L shape extended (4 cells: 3 vertical + 1 horizontal at bottom left)
  static const reverseLShapeExtended = [
    [false, true],
    [false, true],
    [false, true],
    [true, true]
  ];
  
  // Z shape
  static const zShape = [
    [true, true, false],
    [false, true, true]
  ];
  
  // Reverse Z shape
  static const reverseZShape = [
    [false, true, true],
    [true, true, false]
  ];
  
  // Large L shape (3x3) - 3 vertical + 2 horizontal
  static const largeLShape = [
    [true, false],
    [true, false],
    [true, false],
    [true, true]
  ];
  
  // Large reverse L shape (3x3) - 3 vertical + 2 horizontal
  static const largeReverseLShape = [
    [false, true],
    [false, true],
    [false, true],
    [true, true]
  ];
  
  // Plus shape (cross)
  static const plusShape = [
    [false, true, false],
    [true, true, true],
    [false, true, false]
  ];
  
  // U shape
  static const uShape = [
    [true, false, true],
    [true, true, true]
  ];
  
  // Inverted U shape
  static const invertedUShape = [
    [true, true, true],
    [true, false, true]
  ];
  
  // Long L shape (4 cells)
  static const longLShape = [
    [true, false],
    [true, false],
    [true, false],
    [true, true]
  ];
  
  // Long reverse L shape (4 cells)
  static const longReverseLShape = [
    [false, true],
    [false, true],
    [false, true],
    [true, true]
  ];
  
  // Corner shape
  static const cornerShape = [
    [true, true],
    [true, false]
  ];
  
  // Reverse corner shape
  static const reverseCornerShape = [
    [true, true],
    [false, true]
  ];
  
  // Step shape
  static const stepShape = [
    [true, false],
    [true, true],
    [false, true]
  ];
  
  // 4x1 horizontal
  static const horizontal4 = [
    [true, true, true, true]
  ];
  
  // 3x3 square (full)
  static const square3x3 = [
    [true, true, true],
    [true, true, true],
    [true, true, true]
  ];
  
  // Z shape 1x4 (horizontal Z - 2 rows x 4 columns)
  static const zShape4 = [
    [true, true, false, false],
    [false, false, true, true]
  ];
  
  // T shape 1x4 (horizontal T)
  static const tShape4 = [
    [false, true, false, false],
    [true, true, true, false],
    [false, true, false, false]
  ];
  
  // Get all available shapes
  static List<List<List<bool>>> getAllShapes() {
    return [
      single,
      horizontal2,
      horizontal3,
      horizontal4,
      vertical2,
      vertical3,
      square2x2,
      square3x3,
      lShape,
      reverseLShape,
      lShapeExtended,
      reverseLShapeExtended,
      zShape,
      reverseZShape,
      zShape4,
      tShape4,
      largeLShape,
      largeReverseLShape,
      // plusShape removed - too difficult
      // uShape removed - too difficult
      // invertedUShape removed - too difficult
      longLShape,
      longReverseLShape,
      cornerShape,
      reverseCornerShape,
      stepShape,
    ];
  }
  
  // Get random shapes for game
  static List<List<List<bool>>> getRandomShapes(int count) {
    final allShapes = getAllShapes();
    final random = List.generate(count, (index) {
      return allShapes[(index * 7) % allShapes.length];
    });
    return random;
  }
  
  // Get shapes by level (mixed random shapes for faster gameplay)
  static List<List<List<bool>>> getShapesByLevel(int level, int count) {
    final random = Random();
    final allShapes = getAllShapes();
    
    // Level 1: Only the most basic shapes for easy start
    if (level == 1) {
      final simpleShapes = [
        single,      // Single block - easiest
        horizontal2, // 2x1 horizontal
        vertical2,   // 1x2 vertical
        square2x2,   // 2x2 square
      ];
      // Give more weight to single and 2x1 blocks for easier gameplay
      final weights = [4, 3, 3, 2]; // single weight 4, others lower
      
      return List.generate(count, (index) {
        final totalWeight = weights.fold(0, (sum, w) => sum + w);
        var randomValue = random.nextInt(totalWeight);
        for (int i = 0; i < simpleShapes.length; i++) {
          randomValue -= weights[i];
          if (randomValue < 0) {
            return simpleShapes[i];
          }
        }
        return simpleShapes[0];
      });
    }
    
    // From level 2 onwards: Mix all shapes randomly for variety
    // This allows players to break blocks faster with more options
    // All shapes have equal probability for maximum randomness
    return List.generate(count, (index) {
      return allShapes[random.nextInt(allShapes.length)];
    });
  }
}

