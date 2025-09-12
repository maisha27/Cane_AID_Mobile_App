import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/websocket_service.dart';
import '../../core/constants/app_constants.dart';

/// Connection status for the WebSocket
enum ConnectionStatus {
  disconnected,      // WebSocket not connected
  connectedNoData,   // Connected but no recent data
  activeWithData,    // Connected and receiving data
}

/// Simple WebSocket provider following the sample code pattern
/// Direct data storage with Map<String, dynamic> like the sample
class WebSocketProvider extends ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  
  // Simple state management - following your sample pattern
  Map<String, dynamic>? _data;
  bool _isConnected = false;
  String? _serverUrl;
  String? _lastError;
  
  // Data timestamp tracking for connection status
  DateTime? _lastDataReceived;
  
  // Stream subscription for data
  StreamSubscription<Map<String, dynamic>>? _dataSubscription;

  /// Getters - simple like your sample
  Map<String, dynamic>? get data => _data;
  bool get isConnected => _isConnected;
  String? get serverUrl => _serverUrl;
  String? get lastError => _lastError;
  DateTime? get lastDataReceived => _lastDataReceived;
  
  /// Direct data access like your sample
  int? get r => _data?['r'];
  int? get g => _data?['g'];
  int? get b => _data?['b'];
  double? get distance => _data?['distance']?.toDouble();
  double? get latitude => _data?['latitude']?.toDouble();
  double? get longitude => _data?['longitude']?.toDouble();

  /// Check if we received data recently (within seconds)
  bool isDataRecent({int secondsThreshold = 10}) {
    if (_lastDataReceived == null) return false;
    final timeDiff = DateTime.now().difference(_lastDataReceived!);
    return timeDiff.inSeconds <= secondsThreshold;
  }

  /// Get connection status for UI display
  ConnectionStatus getConnectionStatus() {
    if (!_isConnected) {
      return ConnectionStatus.disconnected;
    } else if (isDataRecent()) {
      return ConnectionStatus.activeWithData;
    } else {
      return ConnectionStatus.connectedNoData;
    }
  }

  /// Connect to WebSocket server - simple like your sample
  Future<bool> connectToServer({String? customUrl}) async {
    try {
      _clearError();
      
      final url = customUrl ?? AppConstants.websocketServerUrl;
      _serverUrl = url;
      
      debugPrint("WebSocket Provider: Connecting to $url");
      
      // Simple connection like your sample
      final success = await _webSocketService.connect(customUrl: url);
      
      if (success) {
        _isConnected = true;
        _startListeningToData();
        debugPrint("WebSocket Provider: Connected successfully");
      } else {
        _setError("Failed to connect to WebSocket server");
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _setError("Connection error: $e");
      debugPrint("WebSocket Provider error: $e");
      notifyListeners();
      return false;
    }
  }

  /// Start listening to data - simple like your sample
  void _startListeningToData() {
    debugPrint("📡 DEBUG: Starting to listen for WebSocket data...");
    
    final dataStream = _webSocketService.dataStream;
    if (dataStream == null) {
      debugPrint("📡 ERROR: WebSocket data stream is null");
      return;
    }
    
    debugPrint("📡 DEBUG: WebSocket data stream obtained, setting up listener...");
    
    _dataSubscription = dataStream.listen(
      (newData) {
        // Direct data update like your sample setState pattern
        _data = newData;
        _lastDataReceived = DateTime.now(); // Track when we received data
        _clearError();
        notifyListeners();
        
        debugPrint("📡 SUCCESS: WebSocket Provider data updated - RGB(${newData['r']}, ${newData['g']}, ${newData['b']}), Distance: ${newData['distance']}, GPS: (${newData['latitude']}, ${newData['longitude']}) at ${_lastDataReceived}");
      },
      onError: (error) {
        _setError("Data stream error: $error");
        debugPrint("📡 ERROR: WebSocket Provider data error: $error");
        notifyListeners();
      },
      onDone: () {
        _isConnected = false;
        _setError("Connection closed");
        debugPrint("📡 WARNING: WebSocket Provider connection closed");
        notifyListeners();
      },
    );
    
    debugPrint("📡 DEBUG: WebSocket data listener setup complete");
  }

  /// Disconnect from server
  Future<void> disconnect() async {
    try {
      await _dataSubscription?.cancel();
      await _webSocketService.disconnect();
      
      _isConnected = false;
      _data = null;
      _serverUrl = null;
      _clearError();
      
      debugPrint("WebSocket Provider: Disconnected");
      notifyListeners();
    } catch (e) {
      debugPrint("WebSocket Provider disconnect error: $e");
    }
  }

  /// Send message to server (optional, for future use)
  Future<bool> sendMessage(Map<String, dynamic> message) async {
    return await _webSocketService.sendMessage(message);
  }

  /// Helper methods
  void _setError(String error) {
    _lastError = error;
    debugPrint("WebSocket Provider Error: $error");
  }

  void _clearError() {
    _lastError = null;
  }

  /// Get color as Flutter Color object
  Color? get currentColor {
    if (_data == null) return null;
    final r = _data!['r'] ?? 0;
    final g = _data!['g'] ?? 0;
    final b = _data!['b'] ?? 0;
    return Color.fromRGBO(r, g, b, 1.0);
  }

  /// Get RGB string representation
  String get rgbString {
    if (_data == null) return 'No data';
    return 'RGB(${_data!['r'] ?? 0}, ${_data!['g'] ?? 0}, ${_data!['b'] ?? 0})';
  }

  /// Get coordinates string
  String get coordinatesString {
    if (_data == null) return 'No GPS data';
    final lat = _data!['latitude']?.toDouble() ?? 0.0;
    final lng = _data!['longitude']?.toDouble() ?? 0.0;
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  /// Check if distance indicates obstacle
  bool get isObstacle {
    final dist = distance;
    return dist != null && dist < 50.0;
  }

  /// Get connection statistics (simplified)
  Map<String, dynamic> getConnectionStats() {
    return {
      'isConnected': _isConnected,
      'serverUrl': _serverUrl,
      'hasData': _data != null,
      'lastError': _lastError,
    };
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }
}
