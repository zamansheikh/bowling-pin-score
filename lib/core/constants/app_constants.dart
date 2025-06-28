class AppConstants {
  // Domain Layer - Business logic constants
  static const String appName = 'Bowling Pin Score Tracker';
  static const String appVersion = '1.0.0';

  // Animation Durations (can be used across layers)
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}

// Data Layer Constants
class DataConstants {
  // API Constants
  static const String baseUrl = 'https://api.example.com/';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String currentGameKey = 'current_bowling_game';
  static const String gameHistoryKey = 'bowling_game_history';
}

// Presentation Layer Constants
class UIConstants {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double borderRadiusS = 4.0;
  static const double borderRadiusM = 8.0;
  static const double borderRadiusL = 12.0;
  static const double borderRadiusXL = 16.0;

  // Icon Paths
  static const String iconsPath = 'assets/icons/';
  static const String homeIcon = '${iconsPath}home.svg';
  static const String profileIcon = '${iconsPath}profile.svg';
  static const String settingsIcon = '${iconsPath}settings.svg';
  static const String notificationIcon = '${iconsPath}notification.svg';

  // Image Paths
  static const String imagesPath = 'assets/images/';
  static const String logoImage = '${imagesPath}logo.png';
  static const String placeholderImage = '${imagesPath}placeholder.png';
}
