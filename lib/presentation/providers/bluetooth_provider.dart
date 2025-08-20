import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../../core/services/bluetooth_service.dart';
import '../../core/constants/app_constants.dart';
import 'tts_provider.dart';

/// Provider for managing Bluetooth connection and ESP32 data
/// Handles device discovery, connection state, and sensor data processing
class BluetoothProvider extends ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();
  
  // Connection state
  bool _isInitialized = false;
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  fbp.BluetoothDevice? _connectedDevice;
  List<fbp.BluetoothDevice> _discoveredDevices = [];
  
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
  StreamSubscription<fbp.BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<ESP32Data>? _dataSubscription;
  StreamSubscription<List<fbp.BluetoothDevice>>? _devicesSubscription;

  /// Getters
  bool get isInitialized => _isInitialized;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  fbp.BluetoothDevice? get connectedDevice => _connectedDevice;
  List<fbp.BluetoothDevice> get discoveredDevices => _discoveredDevices;
  ESP32Data? get latestData => _latestData;
  ColorData? get latestColorData => _latestColorData;
  DistanceData? get latestDistanceData => _latestDistanceData;
  GPSData? get latestGPSData => _latestGPSData;
  String? get lastError => _lastError;
  List<ESP32Data> get dataHistory => List.unmodifiable(_dataHistory);
  
  /// Stream of ESP32 data
  Stream<ESP32Data> get dataStream => _bluetoothService.dataStream;

  /// Initialize Bluetooth provider
  Future<void> initialize() async {
    try {
      _isInitialized = await _bluetoothService.initialize();
      
      if (_isInitialized) {
        // Set up stream subscriptions
        _setupStreamSubscriptions();
        debugPrint('Bluetooth provider initialized successfully');
      } else {
        _setError('Bluetooth initialization failed');
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Bluetooth provider initialization error: $e');
      debugPrint('Bluetooth provider initialization error: $e');
      notifyListeners();
    }
  }

  /// Set up stream subscriptions
  void _setupStreamSubscriptions() {
    // Connection state subscription
    _connectionSubscription = _bluetoothService.connectionState.listen((state) {
      _isConnected = state == fbp.BluetoothConnectionState.connected;
      
      if (!_isConnected) {
        _connectedDevice = null;
        _attemptReconnection();
      } else {
        _reconnectAttempts = 0;
        _reconnectTimer?.cancel();
      }
      
      notifyListeners();
    });

    // Data subscription
    _dataSubscription = _bluetoothService.dataStream.listen((data) {
      _handleNewData(data);
    });

    // Devices subscription
    _devicesSubscription = _bluetoothService.discoveredDevices.listen((devices) {
      _discoveredDevices = devices;
      notifyListeners();
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
    debugPrint('Processing ESP32 data for feedback');
  }

  /// Start scanning for ESP32 devices
  Future<void> startScan() async {
    if (!_isInitialized || _isScanning) return;

    try {
      _isScanning = true;
      _clearError();
      notifyListeners();

      await _bluetoothService.startScan(
        timeout: Duration(seconds: AppConstants.bluetoothScanTimeoutSeconds),
      );
      
      debugPrint('Started scanning for ESP32 devices');
    } catch (e) {
      _setError('Error starting scan: $e');
      debugPrint('Error starting scan: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Stop scanning for devices
  Future<void> stopScan() async {
    if (!_isScanning) return;

    try {
      await _bluetoothService.stopScan();
      _isScanning = false;
      notifyListeners();
      debugPrint('Stopped scanning for ESP32 devices');
    } catch (e) {
      _setError('Error stopping scan: $e');
      debugPrint('Error stopping scan: $e');
    }
  }

  /// Connect to ESP32 device
  Future<bool> connectToDevice(fbp.BluetoothDevice device) async {
    if (_isConnecting || _isConnected) return false;

    try {
      _isConnecting = true;
      _clearError();
      notifyListeners();

      final success = await _bluetoothService.connectToDevice(device);
      
      if (success) {
        _connectedDevice = device;
        _isConnected = true;
        _reconnectAttempts = 0;
        debugPrint('Successfully connected to ${device.platformName}');
      } else {
        _setError('Failed to connect to ${device.platformName}');
      }
      
      return success;
    } catch (e) {
      _setError('Connection error: $e');
      debugPrint('Connection error: $e');
      return false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    try {
      _reconnectTimer?.cancel();
      await _bluetoothService.disconnect();
      
      _isConnected = false;
      _connectedDevice = null;
      _clearError();
      
      notifyListeners();
      debugPrint('Disconnected from ESP32 device');
    } catch (e) {
      _setError('Disconnection error: $e');
      debugPrint('Disconnection error: $e');
    }
  }

  /// Request color sensor data
  Future<bool> requestColorData() async {
    if (!_isConnected) {
      _setError('Not connected to ESP32 device');
      return false;
    }

    try {
      return await _bluetoothService.requestColorData();
    } catch (e) {
      _setError('Error requesting color data: $e');
      return false;
    }
  }

  /// Request distance sensor data
  Future<bool> requestDistanceData() async {
    if (!_isConnected) {
      _setError('Not connected to ESP32 device');
      return false;
    }

    try {
      return await _bluetoothService.requestDistanceData();
    } catch (e) {
      _setError('Error requesting distance data: $e');
      return false;
    }
  }

  /// Request GPS data
  Future<bool> requestGPSData() async {
    if (!_isConnected) {
      _setError('Not connected to ESP32 device');
      return false;
    }

    try {
      return await _bluetoothService.requestGPSData();
    } catch (e) {
      _setError('Error requesting GPS data: $e');
      return false;
    }
  }

  /// Request all sensor data
  Future<bool> requestAllData() async {
    if (!_isConnected) {
      _setError('Not connected to ESP32 device');
      return false;
    }

    try {
      return await _bluetoothService.requestAllData();
    } catch (e) {
      _setError('Error requesting all data: $e');
      return false;
    }
  }

  /// Get paired devices
  Future<List<fbp.BluetoothDevice>> getPairedDevices() async {
    try {
      return await _bluetoothService.getPairedDevices();
    } catch (e) {
      _setError('Error getting paired devices: $e');
      return [];
    }
  }

  /// Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    try {
      return await _bluetoothService.isBluetoothEnabled();
    } catch (e) {
      _setError('Error checking Bluetooth state: $e');
      return false;
    }
  }

  /// Turn on Bluetooth
  Future<void> turnOnBluetooth() async {
    try {
      await _bluetoothService.turnOnBluetooth();
      _clearError();
    } catch (e) {
      _setError('Error turning on Bluetooth: $e');
    }
  }

  /// Attempt automatic reconnection
  void _attemptReconnection() {
    if (_reconnectAttempts >= AppConstants.bluetoothReconnectAttempts) {
      _setError('Max reconnection attempts reached');
      return;
    }

    if (_connectedDevice == null) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      Duration(seconds: AppConstants.bluetoothReconnectDelaySeconds),
      () async {
        _reconnectAttempts++;
        debugPrint('Attempting reconnection (${_reconnectAttempts}/${AppConstants.bluetoothReconnectAttempts})');
        
        final success = await connectToDevice(_connectedDevice!);
        if (!success) {
          _attemptReconnection();
        }
      },
    );
  }

  /// Announce color detection via TTS
  void announceColorDetection(TTSProvider ttsProvider) {
    if (_latestColorData?.colorName != null) {
      ttsProvider.announceColorDetection(_latestColorData!.colorName!);
    }
  }

  /// Announce distance warning via TTS
  void announceDistanceWarning(TTSProvider ttsProvider) {
    if (_latestDistanceData != null) {
      ttsProvider.announceDistanceWarning(_latestDistanceData!.distance);
    }
  }

  /// Announce location update via TTS
  void announceLocationUpdate(TTSProvider ttsProvider) {
    if (_latestGPSData?.address != null) {
      ttsProvider.announceLocationUpdate(_latestGPSData!.address!);
    } else if (_latestGPSData != null) {
      ttsProvider.announceLocationUpdate(_latestGPSData!.coordinatesString);
    }
  }

  /// Announce connection status via TTS
  void announceConnectionStatus(TTSProvider ttsProvider) {
    ttsProvider.announceBluetoothStatus(_isConnected);
  }

  /// Get connection status description
  String get connectionStatusDescription {
    if (!_isInitialized) return 'Not initialized';
    if (_isConnecting) return 'Connecting...';
    if (_isConnected) return 'Connected to ${_connectedDevice?.platformName ?? 'Unknown'}';
    if (_isScanning) return 'Scanning for devices...';
    return 'Disconnected';
  }

  /// Get latest distance description
  String get distanceDescription {
    if (_latestDistanceData == null) return 'No distance data';
    
    final distance = _latestDistanceData!.distance;
    if (distance < AppConstants.distanceVeryClose) {
      return 'Very close: ${distance.toStringAsFixed(1)}cm';
    } else if (distance < AppConstants.distanceClose) {
      return 'Close: ${distance.toStringAsFixed(1)}cm';
    } else if (distance < AppConstants.distanceMedium) {
      return 'Medium: ${distance.toStringAsFixed(1)}cm';
    } else {
      return 'Far: ${distance.toStringAsFixed(1)}cm';
    }
  }

  /// Clear data history
  void clearHistory() {
    _dataHistory.clear();
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _lastError = error;
    debugPrint('Bluetooth error: $error');
  }

  /// Clear error message
  void _clearError() {
    _lastError = null;
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    _devicesSubscription?.cancel();
    _bluetoothService.dispose();
    super.dispose();
  }
}
