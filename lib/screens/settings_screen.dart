import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  double _animationSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF101820) : Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppConstants.appBarHeight),
        child: Container(
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        children: [
          _buildSectionTitle('Appearance'),
          const SizedBox(height: AppConstants.smallPadding),
          _buildSettingCard(
            title: 'Dark Mode',
            subtitle: 'Enable dark theme for the app',
            trailing: Switch(
              value: _isDarkMode,
              activeTrackColor: Colors.blueAccent,
              onChanged: (value) {
                setState(() => _isDarkMode = value);
              },
            ),
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          _buildSettingCard(
            title: 'Animation Speed',
            subtitle: 'Control animation speed: ${_animationSpeed.toStringAsFixed(1)}x',
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: _animationSpeed,
                min: 0.5,
                max: 2.0,
                divisions: 6,
                activeColor: Colors.blueAccent,
                onChanged: (value) {
                  setState(() => _animationSpeed = value);
                },
              ),
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          _buildSectionTitle('About'),
          const SizedBox(height: AppConstants.smallPadding),
          _buildSettingCard(
            title: 'App Version',
            subtitle: '1.0.0',
            trailing: const Icon(Icons.info_outline, color: Colors.white54),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildSettingCard(
            title: 'Developer',
            subtitle: 'Duytanodixe',
            trailing: const Icon(Icons.code, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          color: _isDarkMode ? Colors.white70 : Colors.grey[700],
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1C1F26) : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        boxShadow: _isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white54 : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
