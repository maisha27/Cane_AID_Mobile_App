import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../constants/app_constants.dart';
import '../models/esp32_data.dart';

/// WebSocket service for ESP32 communication via laptop bridge
/// Handles connection, data reception, and bridge management
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  // Connection state
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _serverUrl;
  
  // Stream controllers for data
  final StreamController<WebSocketConnectionState> _connectionStateController =
      StreamController<WebSocketConnectionState>.broadcast();
  final StreamController<ESP32Data> _dataController =
      StreamController<ESP32Data>.broadcast();
  final StreamController<String> _rawDataController =
      StreamController<String>.broadcast();

  // Reconnection management
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  bool _shouldReconnect = true;
  
  // Data management
  DateTime? _lastDataReceived;
  int _totalMessagesReceived = 0;
  int _successfulParseCount = 0;
  int _errorParseCount = 0;

  // Getters for streams
  Stream<WebSocketConnectionState> get connectionState => _connectionStateController.stream;
  Stream<ESP32Data> get dataStream => _dataController.stream;
  Stream<String> get rawDataStream => _rawDataController.stream;

  // Connection status
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get serverUrl => _serverUrl;
  DateTime? get lastDataReceived => _lastDataReceived;
  int get totalMessagesReceived => _totalMessagesReceived;
  int get successfulParseCount => _successfulParseCount;
  int get errorParseCount => _errorParseCount;

  /// Initialize WebSocket service
  Future<bool> initialize() async {
    try {
      // Set default server URL
      _serverUrl = AppConstants.websocketServerUrl;
      
      debugPrint("WebSocket service initialized");
      return true;
    } catch (e) {
      debugPrint("WebSocket initialization error: $e");
      return false;
    }
  }

  /// Connect to WebSocket server
  Future<bool> connect({String? customUrl}) async {
    if (_isConnecting || _isConnected) {
      debugPrint("Already connecting or connected to WebSocket");
      return _isConnected;
    }

    try {
      _isConnecting = true;
      _connectionStateController.add(WebSocketConnectionState.connecting);
      
      final url = customUrl ?? _serverUrl ?? AppConstants.websocketServerUrl;
      _serverUrl = url;
      
      debugPrint("Attempting to connect to WebSocket server: $url");
      
      // Create WebSocket connection with timeout
      _channel = IOWebSocketChannel.connect(
        Uri.parse(url),
        connectTimeout: Duration(seconds: AppConstants.websocketTimeoutSeconds),
      );

      // Set up connection monitoring
      await _setupConnectionMonitoring();
      
      // Start data listening
      _startDataListening();
      
      // Start heartbeat
      _startHeartbeat();
      
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      
      _connectionStateController.add(WebSocketConnectionState.connected);
      debugPrint("WebSocket connected successfully to: $url");
      
      return true;
    } catch (e) {
      debugPrint("WebSocket connection error: $e");
      _isConnecting = false;
      _isConnected = false;
      _connectionStateController.add(WebSocketConnectionState.disconnected);
      
      // Attempt reconnection if enabled
      if (_shouldReconnect) {
        _scheduleReconnection();
      }
      
      return false;
    }
  }

  /// Set up connection monitoring
  Future<void> _setupConnectionMonitoring() async {
    if (_channel == null) return;

    // Monitor for connection close
    _channel!.stream.listen(
      (data) {
        // This will be handled in _startDataListening
      },
      onError: (error) {
        debugPrint("WebSocket error: $error");
        _handleConnectionError(error);
      },
      onDone: () {
        debugPrint("WebSocket connection closed");
        _handleConnectionClosed();
      },
    );
  }

  /// Start listening for data from WebSocket
  void _startDataListening() {
    if (_channel == null) return;

    _channel!.stream.listen(
      (data) {
        _handleReceivedData(data);
      },
      onError: (error) {
        debugPrint("WebSocket data error: $error");
        _handleConnectionError(error);
      },
      onDone: () {
        debugPrint("WebSocket data stream closed");
        _handleConnectionClosed();
      },
    );
  }

  /// Handle received data from WebSocket
  void _handleReceivedData(dynamic data) {
    try {
      _lastDataReceived = DateTime.now();
      _totalMessagesReceived++;
      
      String jsonString;
      if (data is String) {
        jsonString = data;
      } else if (data is List<int>) {
        jsonString = utf8.decode(data);
      } else {
        jsonString = data.toString();
      }
      
      debugPrint("WebSocket received: $jsonString");
      _rawDataController.add(jsonString);
      
      // Parse JSON data
      _parseAndProcessData(jsonString);
      
    } catch (e) {
      debugPrint("Error handling WebSocket data: $e");
      _errorParseCount++;
    }
  }

  /// Parse and process ESP32 data from JSON
  void _parseAndProcessData(String jsonString) {
    try {
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Handle different message types
      if (jsonData.containsKey('type')) {
        switch (jsonData['type']) {
          case 'heartbeat':
            _handleHeartbeat(jsonData);
            break;
          case 'esp32_data':
          case 'sensor_data':
            _handleSensorData(jsonData);
            break;
          case 'status':
            _handleStatusMessage(jsonData);
            break;
          default:
            // Try to parse as direct ESP32 data
            _handleSensorData(jsonData);
        }
      } else {
        // Try to parse as direct ESP32 data
        _handleSensorData(jsonData);
      }
      
      _successfulParseCount++;
      
    } catch (e) {
      debugPrint("Error parsing WebSocket JSON: $e");
      _errorParseCount++;
    }
  }

  /// Handle heartbeat messages
  void _handleHeartbeat(Map<String, dynamic> data) {
    debugPrint("Received heartbeat from server");
    // Optionally send heartbeat response
    if (_isConnected) {
      sendMessage({
        'type': 'heartbeat_response',
        'timestamp': DateTime.now().toIso8601String(),
        'client_id': 'cane_aid_app'
      });
    }
  }

  /// Handle sensor data
  void _handleSensorData(Map<String, dynamic> data) {
    try {
      // Extract sensor data from the message
      Map<String, dynamic> sensorData = data;
      
      // If data is nested under a key, extract it
      if (data.containsKey('data')) {
        sensorData = data['data'];
      } else if (data.containsKey('sensor_data')) {
        sensorData = data['sensor_data'];
      }
      
      // Create ESP32Data object
      final esp32Data = ESP32Data.fromJson(sensorData);
      
      // Emit data to listeners
      _dataController.add(esp32Data);
      
      debugPrint("Processed ESP32 data: ${esp32Data.dataSummary}");
      
    } catch (e) {
      debugPrint("Error processing sensor data: $e");
      _errorParseCount++;
    }
  }

  /// Handle status messages from server
  void _handleStatusMessage(Map<String, dynamic> data) {
    final status = data['status'] ?? 'unknown';
    final message = data['message'] ?? '';
    
    debugPrint("Server status: $status - $message");
    
    // Handle specific status messages
    switch (status) {
      case 'esp32_connected':
        debugPrint("ESP32 device connected to server");
        break;
      case 'esp32_disconnected':
        debugPrint("ESP32 device disconnected from server");
        break;
      case 'error':
        debugPrint("Server error: $message");
        break;
    }
  }

  /// Start heartbeat mechanism
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: AppConstants.websocketHeartbeatIntervalSeconds),
      (timer) {
        if (_isConnected) {
          sendMessage({
            'type': 'heartbeat',
            'timestamp': DateTime.now().toIso8601String(),
            'client_id': 'cane_aid_app'
          });
        }
      },
    );
  }

  /// Send message to WebSocket server
  Future<bool> sendMessage(Map<String, dynamic> message) async {
    if (!_isConnected || _channel == null) {
      debugPrint("Cannot send message: WebSocket not connected");
      return false;
    }

    try {
      final jsonString = json.encode(message);
      _channel!.sink.add(jsonString);
      debugPrint("Sent WebSocket message: $jsonString");
      return true;
    } catch (e) {
      debugPrint("Error sending WebSocket message: $e");
      return false;
    }
  }

  /// Handle connection errors
  void _handleConnectionError(dynamic error) {
    debugPrint("WebSocket connection error: $error");
    _isConnected = false;
    _connectionStateController.add(WebSocketConnectionState.error);
    
    if (_shouldReconnect) {
      _scheduleReconnection();
    }
  }

  /// Handle connection closed
  void _handleConnectionClosed() {
    debugPrint("WebSocket connection closed");
    _isConnected = false;
    _connectionStateController.add(WebSocketConnectionState.disconnected);
    
    _cleanup();
    
    if (_shouldReconnect) {
      _scheduleReconnection();
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnection() {
    if (_reconnectAttempts >= AppConstants.websocketReconnectAttempts) {
      debugPrint("Max reconnection attempts reached");
      _shouldReconnect = false;
      return;
    }

    _reconnectAttempts++;
    final delay = _calculateReconnectDelay();
    
    debugPrint("Scheduling reconnection attempt $_reconnectAttempts in ${delay}s");
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (_shouldReconnect && !_isConnected) {
        connect();
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

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    debugPrint("Disconnecting from WebSocket server");
    
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    if (_channel != null) {
      await _channel!.sink.close();
    }
    
    _cleanup();
    _connectionStateController.add(WebSocketConnectionState.disconnected);
  }

  /// Clean up resources
  void _cleanup() {
    _isConnected = false;
    _isConnecting = false;
    _channel = null;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
  }

  /// Reset reconnection attempts
  void resetReconnectionAttempts() {
    _reconnectAttempts = 0;
    _shouldReconnect = true;
  }

  /// Update server URL
  void updateServerUrl(String url) {
    _serverUrl = url;
  }

  /// Get connection statistics
  Map<String, dynamic> getConnectionStats() {
    return {
      'isConnected': _isConnected,
      'serverUrl': _serverUrl,
      'reconnectAttempts': _reconnectAttempts,
      'totalMessages': _totalMessagesReceived,
      'successfulParses': _successfulParseCount,
      'errorParses': _errorParseCount,
      'lastDataReceived': _lastDataReceived?.toIso8601String(),
    };
  }

  /// Dispose of the service
  void dispose() {
    _shouldReconnect = false;
    disconnect();
    _connectionStateController.close();
    _dataController.close();
    _rawDataController.close();
  }
}

/// WebSocket connection states
enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}
