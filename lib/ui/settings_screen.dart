import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  String _difficulty = 'Normal';
  String _theme = 'Dark';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/nengo.png'),
                  fit: BoxFit.cover,
                ),
                color: Colors.blue,
              ),
            ),
          ),
          // Blur overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: -0.2, end: 0),
                      const SizedBox(width: 8),
                      Text(
                        'Settings',
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 100.ms)
                          .slideX(begin: -0.2, end: 0),
                      const Spacer(),
                    ],
                  ),
                ),
                // Settings Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Audio Settings Section
                        _buildSection(
                          title: 'Audio',
                          icon: Icons.volume_up,
                          children: [
                            _buildSwitchTile(
                              title: 'Sound Effects',
                              subtitle: 'Enable game sound effects',
                              value: _soundEnabled,
                              icon: Icons.speaker,
                              onChanged: (value) {
                                setState(() => _soundEnabled = value);
                              },
                              delay: 100.ms,
                            ),
                            _buildSwitchTile(
                              title: 'Background Music',
                              subtitle: 'Play music while playing',
                              value: _musicEnabled,
                              icon: Icons.music_note,
                              onChanged: (value) {
                                setState(() => _musicEnabled = value);
                              },
                              delay: 200.ms,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Game Settings Section
                        _buildSection(
                          title: 'Game',
                          icon: Icons.gamepad,
                          children: [
                            _buildSwitchTile(
                              title: 'Vibration',
                              subtitle: 'Haptic feedback on actions',
                              value: _vibrationEnabled,
                              icon: Icons.vibration,
                              onChanged: (value) {
                                setState(() => _vibrationEnabled = value);
                              },
                              delay: 100.ms,
                            ),
                            _buildDropdownTile(
                              title: 'Difficulty',
                              subtitle: 'Game difficulty level',
                              icon: Icons.speed,
                              value: _difficulty,
                              items: ['Easy', 'Normal', 'Hard', 'Expert'],
                              onChanged: (value) {
                                setState(() => _difficulty = value!);
                              },
                              delay: 200.ms,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Notification Settings Section
                        _buildSection(
                          title: 'Notifications',
                          icon: Icons.notifications,
                          children: [
                            _buildSwitchTile(
                              title: 'Push Notifications',
                              subtitle: 'Receive game notifications',
                              value: _notificationsEnabled,
                              icon: Icons.notifications_active,
                              onChanged: (value) {
                                setState(() => _notificationsEnabled = value);
                              },
                              delay: 100.ms,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Appearance Settings Section
                        _buildSection(
                          title: 'Appearance',
                          icon: Icons.palette,
                          children: [
                            _buildDropdownTile(
                              title: 'Theme',
                              subtitle: 'Choose app theme',
                              icon: Icons.color_lens,
                              value: _theme,
                              items: ['Light', 'Dark', 'Auto'],
                              onChanged: (value) {
                                setState(() => _theme = value!);
                              },
                              delay: 100.ms,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // About Section
                        _buildSection(
                          title: 'About',
                          icon: Icons.info,
                          children: [
                            _buildInfoTile(
                              title: 'Version',
                              subtitle: '1.0.0',
                              icon: Icons.tag,
                              delay: 100.ms,
                            ),
                            _buildInfoTile(
                              title: 'Developer',
                              subtitle: 'Block Blast Team',
                              icon: Icons.code,
                              delay: 200.ms,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.yellow.shade400, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.2, end: 0),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
    Duration delay = const Duration(milliseconds: 0),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.yellow.shade400.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.yellow.shade400, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.yellow.shade400,
          activeTrackColor: Colors.yellow.shade200,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    Duration delay = const Duration(milliseconds: 0),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.yellow.shade400.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.yellow.shade400, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.grey.shade900,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
          ),
          underline: Container(),
          icon: Icon(Icons.arrow_drop_down, color: Colors.yellow.shade400),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Duration delay = const Duration(milliseconds: 0),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.yellow.shade400.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.yellow.shade400, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay)
        .slideX(begin: 0.2, end: 0);
  }
}

