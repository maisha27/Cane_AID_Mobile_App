/// WebSocket configuration for automatic connection
class WebSocketConfig {
  /// Default WebSocket server URL
  /// Update this IP address to match your teammate's laptop IP when they run the bridge server
  static const String defaultServerUrl = 'ws://192.168.0.105:8765';

  /// Connection timeout in seconds
  static const int connectionTimeoutSeconds = 5;

  /// Alternative URLs to try if the default fails
  static const List<String> fallbackUrls = [
    'ws://192.168.1.101:8765',
    'ws://192.168.1.102:8765',
    'ws://192.168.0.100:8765',
    'ws://10.0.0.100:8765',
  ];

  /// Whether to enable automatic connection attempts
  static const bool enableAutoConnection = true;

  /// Whether to show connection status messages
  static const bool showConnectionMessages = true;
}
