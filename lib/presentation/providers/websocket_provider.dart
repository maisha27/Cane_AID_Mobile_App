import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/websocket_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/esp32_data.dart';

/// Provider for managing WebSocket connection and ESP32 data via laptop bridge
/// Handles server connection state and sensor data processing
class WebSocketProvider extends ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  
  // Connection state
  bool _isInitialized = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  String? _serverUrl;
  
  // Sensor data
  ESP32Data? _latestData;
  ColorData? _latestColorData;
  DistanceData? _latestDistanceData;
  GPSData? _latestGPSData;
  
  // Error handling
  String? _lastError;
  
  // Data history for analysis
  final List<ESP32Data> _dataHistory = [];
  static const int maxHistoryLength = 100;
  
  // Auto-reconnection
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  
  // Stream subscriptions
  StreamSubscription<WebSocketConnectionState>? _connectionSubscription;
  StreamSubscription<ESP32Data>? _dataSubscription;
  StreamSubscription<String>? _rawDataSubscription;

  /// Getters
  bool get isInitialized => _isInitialized;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  String? get serverUrl => _serverUrl;
  ESP32Data? get latestData => _latestData;
  ColorData? get latestColorData => _latestColorData;
  DistanceData? get latestDistanceData => _latestDistanceData;
  GPSData? get latestGPSData => _latestGPSData;
  String? get lastError => _lastError;
  List<ESP32Data> get dataHistory => List.unmodifiable(_dataHistory);
  int get reconnectAttempts => _reconnectAttempts;
  
  /// Stream of ESP32 data
  Stream<ESP32Data> get dataStream => _webSocketService.dataStream;
  Stream<String> get rawDataStream => _webSocketService.rawDataStream;

  /// Initialize WebSocket provider
  Future<void> initialize() async {
    try {
      _isInitialized = await _webSocketService.initialize();
      
      if (_isInitialized) {
        _serverUrl = AppConstants.websocketServerUrl;
        // Set up stream subscriptions
        _setupStreamSubscriptions();
        debugPrint('WebSocket provider initialized successfully');
      } else {
        _setError('WebSocket initialization failed');
      }
      
      notifyListeners();
    } catch (e) {
      _setError('WebSocket provider initialization error: $e');
      debugPrint('WebSocket provider initialization error: $e');
      notifyListeners();
    }
  }

  /// Set up stream subscriptions
  void _setupStreamSubscriptions() {
    // Connection state subscription
    _connectionSubscription = _webSocketService.connectionState.listen((state) {
      _isConnected = state == WebSocketConnectionState.connected;
      _isConnecting = state == WebSocketConnectionState.connecting;
      
      if (state == WebSocketConnectionState.disconnected || 
          state == WebSocketConnectionState.error) {
        _serverUrl = null;
        _attemptReconnection();
      } else if (state == WebSocketConnectionState.connected) {
        _reconnectAttempts = 0;
        _reconnectTimer?.cancel();
        _clearError();
      }
      
      notifyListeners();
    });

    // Data subscription
    _dataSubscription = _webSocketService.dataStream.listen((data) {
      _handleNewData(data);
    });

    // Raw data subscription for debugging
    _rawDataSubscription = _webSocketService.rawDataStream.listen((rawData) {
      debugPrint('Raw WebSocket data: $rawData');
    });
  }

  /// Handle new ESP32 data
  void _handleNewData(ESP32Data data) {
    _latestData = data;
    _clearError();
    
    // Update individual sensor data
    if (data.colorData != null) {
      _latestColorData = data.colorData;
    }
    
    if (data.distanceData != null) {
      _latestDistanceData = data.distanceData;
    }
    
    if (data.gpsData != null) {
      _latestGPSData = data.gpsData;
    }
    
    // Add to history
    _addToHistory(data);
    
    // Process data for user feedback
    _processDataForFeedback(data);
    
    notifyListeners();
  }

  /// Add data to history
  void _addToHistory(ESP32Data data) {
    _dataHistory.add(data);
    
    // Limit history size
    if (_dataHistory.length > maxHistoryLength) {
      _dataHistory.removeAt(0);
    }
  }

  /// Process data for user feedback
  void _processDataForFeedback(ESP32Data data) {
    // This will be called by the UI to trigger TTS announcements
    // The actual TTS calls should be made by the UI components
    debugPrint('Processing ESP32 data for feedback: ${data.dataSummary}');
  }

  /// Connect to WebSocket server
  Future<bool> connectToServer({String? customUrl}) async {
    if (_isConnecting || _isConnected) return false;

    try {
      _isConnecting = true;
      _clearError();
      notifyListeners();

      final success = await _webSocketService.connect(customUrl: customUrl);
      
      if (success) {
        _serverUrl = customUrl ?? _serverUrl;
        debugPrint('Connected to WebSocket server: $_serverUrl');
      } else {
        _setError(AppConstants.errorWebSocketConnectionFailed);
      }
      
      return success;
    } catch (e) {
      _setError('Error connecting to server: $e');
      debugPrint('Error connecting to WebSocket server: $e');
      return false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    try {
      _reconnectTimer?.cancel();
      await _webSocketService.disconnect();
      
      _isConnected = false;
      _isConnecting = false;
      _serverUrl = null;
      
      notifyListeners();
      debugPrint('Disconnected from WebSocket server');
    } catch (e) {
      _setError('Error disconnecting: $e');
      debugPrint('Error disconnecting from WebSocket server: $e');
    }
  }

  /// Send message to server
  Future<bool> sendMessage(Map<String, dynamic> message) async {
    return await _webSocketService.sendMessage(message);
  }

  /// Update server URL
  void updateServerUrl(String url) {
    _serverUrl = url;
    _webSocketService.updateServerUrl(url);
    notifyListeners();
  }

  /// Attempt reconnection
  void _attemptReconnection() {
    if (_reconnectAttempts >= AppConstants.websocketReconnectAttempts) {
      _setError('Maximum reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delay = _calculateReconnectDelay();
    
    debugPrint('Scheduling reconnection attempt $_reconnectAttempts in ${delay}s');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (!_isConnected && _serverUrl != null) {
        connectToServer();
      }
    });
  }

  /// Calculate reconnection delay with exponential backoff
  int _calculateReconnectDelay() {
    final baseDelay = AppConstants.websocketReconnectDelaySeconds;
    final maxDelay = AppConstants.websocketMaxReconnectDelaySeconds;
    
    // Exponential backoff: 3s, 6s, 12s, 24s, 30s (max)
    final delay = (baseDelay * (1 << (_reconnectAttempts - 1))).clamp(baseDelay, maxDelay);
    return delay;
  }

  /// Reset reconnection attempts
  void resetReconnectionAttempts() {
    _reconnectAttempts = 0;
    _webSocketService.resetReconnectionAttempts();
  }

  /// Get connection statistics
  Map<String, dynamic> getConnectionStats() {
    final serviceStats = _webSocketService.getConnectionStats();
    return {
      ...serviceStats,
      'providerReconnectAttempts': _reconnectAttempts,
      'dataHistoryCount': _dataHistory.length,
      'lastError': _lastError,
    };
  }

  /// Clear data history
  void clearDataHistory() {
    _dataHistory.clear();
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _lastError = error;
    debugPrint('WebSocket Provider Error: $error');
  }

  /// Clear error message
  void _clearError() {
    _lastError = null;
  }

  /// Check if server is reachable
  Future<bool> pingServer() async {
    if (!_isConnected) return false;
    
    try {
      final success = await sendMessage({
        'type': 'ping',
        'timestamp': DateTime.now().toIso8601String(),
      });
      return success;
    } catch (e) {
      debugPrint('Ping failed: $e');
      return false;
    }
  }

  /// Request specific data from ESP32
  Future<bool> requestSensorData({
    bool color = true,
    bool distance = true,
    bool gps = true,
  }) async {
    if (!_isConnected) return false;
    
    try {
      final success = await sendMessage({
        'type': 'request_data',
        'sensors': {
          'color': color,
          'distance': distance,
          'gps': gps,
        },
        'timestamp': DateTime.now().toIso8601String(),
      });
      return success;
    } catch (e) {
      debugPrint('Request sensor data failed: $e');
      return false;
    }
  }

  /// Get latest data summary for UI display
  String getDataSummary() {
    if (_latestData == null) return 'No data received';
    return _latestData!.dataSummary;
  }

  /// Get connection status text
  String getConnectionStatusText() {
    if (_isConnecting) return 'Connecting to server...';
    if (_isConnected) return 'Connected to ESP32 server';
    if (_lastError != null) return 'Error: $_lastError';
    return 'Disconnected';
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    _rawDataSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }
}
