import 'package:flutter/material.dart';
import 'home_page.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  void _navigateToGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate approximate position of Play button
    // Based on typical mobile game layout, Play button is usually in center-bottom area
    // Adjust these values based on your actual image layout
    final playButtonTop = screenHeight * 0.55; // Approximately 55% from top
    final playButtonHeight = screenHeight * 0.12; // Button height ~12% of screen
    final playButtonWidth = screenWidth * 0.6; // Button width ~60% of screen
    final playButtonLeft = (screenWidth - playButtonWidth) / 2; // Centered horizontally

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/screenPLAY.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Invisible tap area for Play button
          Positioned(
            left: playButtonLeft,
            top: playButtonTop,
            width: playButtonWidth,
            height: playButtonHeight,
            child: GestureDetector(
              onTap: _navigateToGame,
              child: Container(
                color: Colors.transparent,
                // Optional: Uncomment to see the tap area during development
                // color: Colors.red.withOpacity(0.3),
                child: const Center(
                  child: SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

