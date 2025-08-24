/// Route names for the Cane AID application
class AppRoutes {
  AppRoutes._();

  // Main Routes
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String permissions = '/permissions';
  static const String setup = '/setup';
  static const String home = '/home';

  // Feature Routes
  static const String colorDetection = '/color-detection';
  static const String distanceDetection = '/distance-detection';
  static const String location = '/location';
  static const String bluetooth = '/bluetooth';
  static const String websocket = '/websocket';
  static const String websocketTest = '/websocket-test';

  // Settings Routes
  static const String settings = '/settings';
  static const String voiceSettings = '/settings/voice';
  static const String caretakerSettings = '/settings/caretaker';
  static const String accessibilitySettings = '/settings/accessibility';

  // Help Routes
  static const String help = '/help';
  static const String tutorial = '/tutorial';

  // All routes list for validation
  static const List<String> allRoutes = [
    splash,
    welcome,
    permissions,
    setup,
    home,
    colorDetection,
    distanceDetection,
    location,
    bluetooth,
    websocket,
    websocketTest,
    settings,
    voiceSettings,
    caretakerSettings,
    accessibilitySettings,
    help,
    tutorial,
  ];
}
