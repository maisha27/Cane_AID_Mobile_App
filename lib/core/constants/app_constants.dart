/// App-wide constants for the Cane AID application
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'Cane AID';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Assistive technology for visually impaired users';

  // Supported Languages
  static const String englishLanguageCode = 'en';
  static const List<String> supportedLanguages = [
    englishLanguageCode,
  ];

  // Default Settings
  static const String defaultLanguage = englishLanguageCode;
  static const double defaultTTSSpeed = 0.8;
  static const double defaultTTSPitch = 1.0;
  static const double defaultTTSVolume = 1.0;

  // Storage Keys
  static const String storageLanguageKey = 'selected_language';
  static const String storageTTSSpeedKey = 'tts_speed';
  static const String storageTTSPitchKey = 'tts_pitch';
  static const String storageTTSVolumeKey = 'tts_volume';
  static const String storageCaretakerContactKey = 'caretaker_contact';
  static const String storageThemeModeKey = 'theme_mode';
  static const String storageFirstLaunchKey = 'first_launch';
  static const String storagePermissionsGrantedKey = 'permissions_granted';

  // WebSocket Configuration (new)
  static const String websocketServerUrl = 'ws://192.168.0.102:8765';
  static const int websocketTimeoutSeconds = 10;
  static const int websocketReconnectAttempts = 5;
  static const int websocketReconnectDelaySeconds = 3;
  static const int websocketHeartbeatIntervalSeconds = 30;
  static const int websocketMaxReconnectDelaySeconds = 30;

  // Sensor Data Configuration
  static const int sensorDataTimeoutSeconds = 5;
  static const int colorDetectionDelayMs = 1000; // Delay between color readings
  static const int distanceDetectionDelayMs = 500; // Delay between distance readings
  static const int locationUpdateIntervalSeconds = 30;

  // Distance Thresholds (in centimeters)
  static const double distanceVeryClose = 20.0;    // Red alert
  static const double distanceClose = 50.0;        // Orange warning
  static const double distanceMedium = 100.0;      // Yellow caution
  static const double distanceFar = 200.0;         // Green safe

  // Voice Feedback Configuration
  static const int voiceFeedbackDelayMs = 500;     // Delay before speaking
  static const int voiceAnnouncementCooldownMs = 3000; // Cooldown between same announcements

  // Haptic Feedback Configuration
  static const int hapticFeedbackDurationMs = 200;
  static const int hapticPatternVibration = 100;   // Single vibration
  static const List<int> hapticPatternWarning = [100, 50, 100]; // Warning pattern
  static const List<int> hapticPatternAlert = [200, 100, 200, 100, 200]; // Alert pattern

  // Network Configuration
  static const int networkTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 2;

  // Color API Configuration
  static const String colorAPIBaseUrl = 'https://www.thecolorapi.com';
  static const String colorAPIEndpoint = '/identify';

  // Location Configuration
  static const double locationAccuracyMeters = 10.0;
  static const int locationTimeoutSeconds = 30;

  // UI Configuration
  static const int loadingTimeoutSeconds = 30;
  static const int animationDurationMs = 300;
  static const int splashScreenDurationMs = 3000;

  // Error Messages
  static const String errorLocationNotAvailable = 'Location services not available';
  static const String errorLocationPermissionDenied = 'Location permission denied';
  static const String errorMicrophonePermissionDenied = 'Microphone permission denied';
  static const String errorNetworkNotAvailable = 'Network not available';
  static const String errorSensorDataTimeout = 'Sensor data timeout';
  static const String errorDeviceNotFound = 'ESP32 device not found';
  static const String errorConnectionFailed = 'Connection failed';

  // WebSocket Error Messages (new)
  static const String errorWebSocketConnectionFailed = 'WebSocket connection failed';
  static const String errorWebSocketServerUnreachable = 'Server unreachable';
  static const String errorWebSocketDataTimeout = 'WebSocket data timeout';
  static const String errorWebSocketInvalidData = 'Invalid data received from server';
  static const String errorWebSocketAuthenticationFailed = 'Server authentication failed';

  // Success Messages
  static const String successLocationShared = 'Location shared with caretaker';

  // WebSocket Success Messages (new)
  static const String successWebSocketConnected = 'Connected to ESP32 server successfully';
  static const String successWebSocketDataReceived = 'Receiving sensor data from ESP32';
  static const String successWebSocketReconnected = 'Reconnected to server successfully';

  // Validation Constants
  static const int minCaretakerNameLength = 2;
  static const int maxCaretakerNameLength = 50;
  static const String phoneNumberPattern = r'^\+?[\d\s\-\(\)]+$';

  // File Paths
  static const String logFileName = 'cane_aid_logs.txt';
  static const String exportDataFileName = 'cane_aid_data.json';

  // Permissions
  static const List<String> requiredPermissions = [
    'location',
    'locationWhenInUse',
    'microphone',
  ];

  // Accessibility
  static const double minFontSize = 14.0;
  static const double maxFontSize = 24.0;
  static const double defaultFontSize = 16.0;
  static const int minContrastRatio = 4; // WCAG AA standard

  // Debug Configuration
  static const bool enableLogging = true;
  static const bool enableDebugMode = false;
  static const int maxLogFileSize = 1024 * 1024; // 1MB
}
