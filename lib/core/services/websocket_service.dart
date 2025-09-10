import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/app_constants.dart';

/// Simple WebSocket service following the sample code pattern
/// Direct connection and JSON parsing without complex state management
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  // Simple connection state - following your sample pattern
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _serverUrl;

  // Connection status
  bool get isConnected => _isConnected;
  String? get serverUrl => _serverUrl;

  /// Connect to WebSocket server - simple like your sample
  Future<bool> connect({String? customUrl}) async {
    if (_isConnected) {
      debugPrint("Already connected to WebSocket");
      return true;
    }

    try {
      final url = customUrl ?? AppConstants.websocketServerUrl;
      _serverUrl = url;
      
      debugPrint("Connecting to WebSocket: $url");
      
      // Simple direct connection like your sample
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _isConnected = true;
      debugPrint("WebSocket connected successfully");
      
      return true;
    } catch (e) {
      debugPrint("WebSocket connection error: $e");
      _isConnected = false;
      return false;
    }
  }

  /// Get data stream - simple like your sample
  Stream<Map<String, dynamic>>? get dataStream {
    if (_channel == null) return null;
    
    return _channel!.stream.map((message) {
      try {
        // Direct JSON parsing like your sample
        final decoded = jsonDecode(message);
        debugPrint("WebSocket received: $decoded");
        return decoded as Map<String, dynamic>;
      } catch (e) {
        debugPrint("Error parsing JSON: $e");
        return <String, dynamic>{}; // Return empty map on error
      }
    });
  }

  /// Send message to server (optional, for future use)
  Future<bool> sendMessage(Map<String, dynamic> message) async {
    if (!_isConnected || _channel == null) {
      debugPrint("Cannot send message: WebSocket not connected");
      return false;
    }

    try {
      final jsonString = jsonEncode(message);
      _channel!.sink.add(jsonString);
      debugPrint("Sent WebSocket message: $jsonString");
      return true;
    } catch (e) {
      debugPrint("Error sending WebSocket message: $e");
      return false;
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    debugPrint("Disconnecting from WebSocket server");
    
    if (_channel != null) {
      await _channel!.sink.close();
    }
    
    _isConnected = false;
    _channel = null;
  }

  /// Dispose of the service
  void dispose() {
    disconnect();
  }
}
