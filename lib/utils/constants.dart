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
  
  // Scoring
  static const int pointsPerLine = 100;
  static const int pointsPerBlock = 10;
  
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
  
  // Grid colors
  static const int gridBackgroundColor = 0xFF1A1A2E;
  static const int gridLineColor = 0xFFFFFFFF;
  static const int emptyCellColor = 0xFF16213E;
  
  // Animation durations
  static const Duration lineClearAnimation = Duration(milliseconds: 500);
}

