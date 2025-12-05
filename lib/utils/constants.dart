class GameConstants {
  // Grid dimensions
  static const int gridRows = 8;
  static const int gridCols = 8;
  
  // Cell and block sizes
  static const double cellSize = 40.0;
  static const double blockSize = 40.0;
  
  // Game settings
  static const int maxBlocksInQueue = 3;
  static const int initialScore = 0;
  
  // Scoring - Enhanced with combo multipliers
  static const int pointsPerLine = 100;
  static const int pointsPerBlock = 10;
  static const int baseComboMultiplier = 1;
  static const int maxComboMultiplier = 10;
  
  // Bonus points for multiple lines cleared at once
  static const int doubleLineBonus = 50;
  static const int tripleLineBonus = 150;
  static const int quadLineBonus = 300;
  static const int megaLineBonus = 500;
  
  // Colors (as ARGB integers) - Bright and vivid
  static const List<int> blockColors = [
    0xFFFF6B6B, // Bright Red
    0xFF4ECDC4, // Bright Teal
    0xFF45B7D1, // Bright Blue
    0xFF96CEB4, // Bright Green
    0xFFFFEAA7, // Bright Yellow
    0xFFFFA726, // Bright Orange
    0xFFAB47BC, // Bright Purple
    0xFFEC407A, // Bright Pink
  ];
  
  // Grid colors - Professional wood-themed design
  static const int gridBackgroundColor = 0xFF8B6F47; // Warm wood brown
  static const int gridLineColor = 0xFFD4A574; // Light wood accent
  static const int emptyCellColor = 0xFF6B4E37; // Darker wood brown
  static const int gridBorderColor = 0xFF5C3E2A; // Dark wood border
  
  // Animation durations
  static const Duration lineClearAnimation = Duration(milliseconds: 500);
}

