/// WebSocket configuration for automatic connection
class WebSocketConfig {
  /// Default WebSocket server URL
  /// Update this IP address to match your teammate's laptop IP when they run the bridge server
  static const String defaultServerUrl = 'ws://10.103.136.46:8765';

  /// Connection timeout in seconds
  static const int connectionTimeoutSeconds = 5;

  /// Alternative URLs to try if the default fails
  static const List<String> fallbackUrls = [
    'ws://192.168.0.103:8765',
    'ws://192.168.1.102:8765',
    'ws://192.168.1.100:8765',
    'ws://10.0.0.100:8765',
  ];

  /// Whether to enable automatic connection attempts
  static const bool enableAutoConnection = true;

  /// Whether to show connection status messages
  static const bool showConnectionMessages = true;
}
