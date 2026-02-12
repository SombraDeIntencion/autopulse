class AppConstants {
  // App Info
  static const String appName = 'AutoPulse';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Sistema integral de gestión de talleres automotrices';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String vehiclesCollection = 'vehicles';
  static const String ordersCollection = 'orders';
  static const String subscriptionsCollection = 'subscriptions';

  // Storage Paths
  static const String vehiclePhotosPath = 'vehicle_photos';
  static const String documentsPath = 'documents';
  static const String profilePhotosPath = 'profile_photos';

  // Shared Preferences Keys
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  static const String userIdKey = 'userId';
  static const String isLoggedInKey = 'isLoggedIn';
  static const String biometricEnabledKey = 'biometricEnabled';
  static const String savedEmailKey = 'savedEmail';
  static const String savedUserIdKey = 'savedUserId';

  // Image Compression
  static const int imageQuality = 70;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int imageCompressionQuality = 70;
  static const int imageMaxWidth = 1920;
  static const int imageMaxHeight = 1080;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Tab IDs (7 workflow stages)
  static const String tabReception = 'reception';
  static const String tabDiagnosis = 'diagnosis';
  static const String tabParts = 'parts';
  static const String tabApproval = 'approval';
  static const String tabRepair = 'repair';
  static const String tabControl = 'control';
  static const String tabDelivery = 'delivery';

  // Vehicle Types
  static const List<String> vehicleTypes = [
    'bus',
    'car',
    'electricBike',
    'bicycle',
    'truck',
    'pickup',
  ];

  // Supported Languages
  static const List<String> supportedLanguages = [
    'es', // Español
    'en', // English
    'pt', // Português
    'fr', // Français
    'de', // Deutsch
    'it', // Italiano
    'zh', // 中文
    'ja', // 日本語
    'ru', // Русский
  ];

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxObservationsLength = 1000;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 16.0;
  static const double cardElevation = 0.0;

  // Subscription Tiers
  static const String basicSubscription = 'basic';
  static const String professionalSubscription = 'professional';
  static const String enterpriseSubscription = 'enterprise';
}
