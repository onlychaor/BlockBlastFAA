import 'dart:math';

class Helpers {
  static final Random _random = Random();
  
  static int getRandomColor(List<int> colors) {
    return colors[_random.nextInt(colors.length)];
  }
}

