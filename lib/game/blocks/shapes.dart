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
  
  // Get all available shapes
  static List<List<List<bool>>> getAllShapes() {
    return [
      single,
      horizontal2,
      horizontal3,
      vertical2,
      vertical3,
      square2x2,
      lShape,
      reverseLShape,
      lShapeExtended,
      reverseLShapeExtended,
      zShape,
      reverseZShape,
      largeLShape,
      largeReverseLShape,
      plusShape,
      uShape,
      invertedUShape,
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
  
  // Get shapes by level (higher level = more complex shapes)
  static List<List<List<bool>>> getShapesByLevel(int level, int count) {
    final random = Random();
    
    // Define shape difficulty levels
    final easyShapes = [single, horizontal2, vertical2, square2x2, cornerShape, reverseCornerShape];
    final mediumShapes = [horizontal3, vertical3, lShape, reverseLShape, lShapeExtended, reverseLShapeExtended, uShape, invertedUShape];
    final hardShapes = [zShape, reverseZShape, plusShape, stepShape, longLShape, longReverseLShape];
    final expertShapes = [largeLShape, largeReverseLShape];
    
    // Determine which shapes to use based on level with weighted probability
    List<List<List<bool>>> availableShapes;
    List<int> weights;
    
    if (level <= 2) {
      // Level 1-2: Easy shapes + basic L shapes
      availableShapes = [...easyShapes, lShape, reverseLShape];
      weights = [
        ...List.filled(easyShapes.length, 5), // Easy shapes
        ...List.filled(2, 2), // Basic L shapes
      ];
    } else if (level <= 4) {
      // Level 3-4: Easy + medium including extended L shapes (60% easy, 40% medium)
      availableShapes = [...easyShapes, ...mediumShapes.take(6)];
      weights = [
        ...List.filled(easyShapes.length, 6), // Easy shapes weight 6
        ...List.filled(6, 4), // Medium shapes weight 4 (includes extended L shapes)
      ];
    } else if (level <= 7) {
      // Level 5-7: Easy + Medium + some hard (50% easy, 40% medium, 10% hard)
      availableShapes = [...easyShapes, ...mediumShapes, ...hardShapes.take(3)];
      weights = [
        ...List.filled(easyShapes.length, 5), // Easy
        ...List.filled(mediumShapes.length, 4), // Medium
        ...List.filled(3, 1), // Hard
      ];
    } else if (level <= 10) {
      // Level 8-10: Medium + Hard (40% medium, 60% hard)
      availableShapes = [...mediumShapes, ...hardShapes];
      weights = [
        ...List.filled(mediumShapes.length, 4), // Medium
        ...List.filled(hardShapes.length, 6), // Hard
      ];
    } else {
      // Level 11+: All shapes including expert (30% medium, 50% hard, 20% expert)
      availableShapes = [...mediumShapes, ...hardShapes, ...expertShapes];
      weights = [
        ...List.filled(mediumShapes.length, 3), // Medium
        ...List.filled(hardShapes.length, 5), // Hard
        ...List.filled(expertShapes.length, 2), // Expert
      ];
    }
    
    // Generate random shapes with weighted probability
    return List.generate(count, (index) {
      // Calculate total weight
      final totalWeight = weights.fold(0, (sum, weight) => sum + weight);
      var randomValue = random.nextInt(totalWeight);
      
      // Select shape based on weight
      for (int i = 0; i < availableShapes.length; i++) {
        randomValue -= weights[i];
        if (randomValue < 0) {
          return availableShapes[i];
        }
      }
      // Fallback to first shape
      return availableShapes[0];
    });
  }
}

