class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Auto Tap Pro';
  static const String appVersion = '1.0.0';

  // Default Profile
  static const String defaultProfileId = 'default';

  // Storage Keys
  static const String profilesKey = 'profiles';
  static const String activeProfileKey = 'active_profile_id';
  static const String dotsKey = 'dots';
  static const String toolbarPositionKey = 'toolbar_position';

  // Dot Default Values
  static const int defaultActionInterval = 1000; // ms
  static const int defaultHoldTime = 500; // ms
  static const int defaultAntiDetection = 0; // px
  static const int defaultStartDelay = 0; // ms
  static const int minValue = 0;
  static const int maxValue = 100000; // 100 seconds max
  static const int maxAntiDetectionRadius = 100; // px

  // Toolbar Default Position
  static const double defaultToolbarPosX = 350.0;
  static const double defaultToolbarPosY = 200.0;

  // Dot Widget Size
  static const double dotWidgetSize = 70.0;
  static const double dotCrosshairSize = 60.0;
  static const double dotCrosshairStrokeWidth = 2.0;
  static const double dotCenterDotRadius = 3.0;

  // Profile Avatar Size
  static const double profileAvatarRadius = 26.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 120);
  static const Duration mediumAnimation = Duration(milliseconds: 150);
  static const Duration longAnimation = Duration(milliseconds: 300);

  // UI Sizes
  static const double toolbarIconSize = 24.0;
  static const double fabSize = 65.0;
  static const double profileButtonHeight = 180.0;
  static const double profileButtonWidth = 180.0;
  static const double appBarHeight = 100.0;
  static const double miniAppBarHeight = 60.0;

  // Border Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 14.0;
  static const double extraLargeRadius = 16.0;
  static const double ultraLargeRadius = 20.0;

  // Padding
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 20.0;
  static const double extraPadding = 24.0;

  // Colors (hex values as ints)
  static const int primaryDark = 0xFF1565C0;
  static const int primaryLight = 0xFF42A5F5;
  static const int backgroundDark = 0xFF101820;
  static const int cardDark = 0xFF1C1F26;
  static const int inputDark = 0xFF2C2F36;
  static const int surfaceDark = 0xFF1F1F1F;
  static const int inputSurfaceDark = 0xFF2A2A2A;
}
