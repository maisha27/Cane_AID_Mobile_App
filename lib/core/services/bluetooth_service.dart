import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../constants/app_constants.dart';

/// Bluetooth service for ESP32 communication
/// Handles connection, data reception, and device management
class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  // Connection state
  fbp.BluetoothDevice? _connectedDevice;
  fbp.BluetoothCharacteristic? _dataCharacteristic;
  StreamSubscription<fbp.BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _dataSubscription;

  // Stream controllers for data
  final StreamController<fbp.BluetoothConnectionState> _connectionStateController =
      StreamController<fbp.BluetoothConnectionState>.broadcast();
  final StreamController<ESP32Data> _dataController =
      StreamController<ESP32Data>.broadcast();
  final StreamController<List<fbp.BluetoothDevice>> _devicesController =
      StreamController<List<fbp.BluetoothDevice>>.broadcast();

  // ESP32 Service and Characteristic UUIDs
  static const String ESP32_SERVICE_UUID = "12345678-1234-1234-1234-123456789abc";
  static const String ESP32_DATA_CHARACTERISTIC_UUID = "87654321-4321-4321-4321-cba987654321";

  // Getters for streams
  Stream<fbp.BluetoothConnectionState> get connectionState => _connectionStateController.stream;
  Stream<ESP32Data> get dataStream => _dataController.stream;
  Stream<List<fbp.BluetoothDevice>> get discoveredDevices => _devicesController.stream;

  // Connection status
  bool get isConnected => _connectedDevice != null;
  fbp.BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Initialize Bluetooth service
  Future<bool> initialize() async {
    try {
      // Check if Bluetooth is supported
      if (await fbp.FlutterBluePlus.isSupported == false) {
        debugPrint("Bluetooth not supported by this device");
        return false;
      }

      // Check adapter state
      final adapterState = await fbp.FlutterBluePlus.adapterState.first;
      if (adapterState != fbp.BluetoothAdapterState.on) {
        debugPrint("Bluetooth is not turned on");
        return false;
      }

      debugPrint("Bluetooth service initialized successfully");
      return true;
    } catch (e) {
      debugPrint("Bluetooth initialization error: $e");
      return false;
    }
  }

  /// Start scanning for ESP32 devices
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      // Stop any ongoing scan
      await fbp.FlutterBluePlus.stopScan();

      // Clear previous devices
      _devicesController.add([]);

      // Start scanning
      await fbp.FlutterBluePlus.startScan(
        timeout: timeout,
        withServices: [fbp.Guid(ESP32_SERVICE_UUID)], // Look for our specific service
      );

      // Listen for scan results
      fbp.FlutterBluePlus.scanResults.listen((results) {
        final devices = results.map((r) => r.device).toList();
        _devicesController.add(devices);
        debugPrint("Found ${devices.length} ESP32 devices");
      });

      debugPrint("Started scanning for ESP32 devices");
    } catch (e) {
      debugPrint("Error starting Bluetooth scan: $e");
    }
  }

  /// Stop scanning for devices
  Future<void> stopScan() async {
    try {
      await fbp.FlutterBluePlus.stopScan();
      debugPrint("Stopped Bluetooth scan");
    } catch (e) {
      debugPrint("Error stopping Bluetooth scan: $e");
    }
  }

  /// Connect to ESP32 device
  Future<bool> connectToDevice(fbp.BluetoothDevice device) async {
    try {
      debugPrint("Attempting to connect to device: ${device.platformName}");

      // Disconnect from current device if connected
      if (isConnected) {
        await disconnect();
      }

      // Connect to the device
      await device.connect(timeout: const Duration(seconds: 15));
      _connectedDevice = device;

      // Listen for connection state changes
      _connectionSubscription = device.connectionState.listen((state) {
        _connectionStateController.add(state);
        
        if (state == fbp.BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });

      // Discover services
      await _discoverServicesAndCharacteristics();

      debugPrint("Successfully connected to ESP32 device");
      return true;
    } catch (e) {
      debugPrint("Error connecting to device: $e");
      _connectedDevice = null;
      return false;
    }
  }

  /// Discover services and characteristics
  Future<void> _discoverServicesAndCharacteristics() async {
    if (_connectedDevice == null) return;

    try {
      // Discover services
      List<fbp.BluetoothService> services = await _connectedDevice!.discoverServices();
      
      // Find our ESP32 service
      fbp.BluetoothService? esp32Service;
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == ESP32_SERVICE_UUID.toLowerCase()) {
          esp32Service = service;
          break;
        }
      }

      if (esp32Service == null) {
        throw Exception("ESP32 service not found");
      }

      // Find the data characteristic
      for (var characteristic in esp32Service.characteristics) {
        if (characteristic.uuid.toString().toLowerCase() == ESP32_DATA_CHARACTERISTIC_UUID.toLowerCase()) {
          _dataCharacteristic = characteristic;
          break;
        }
      }

      if (_dataCharacteristic == null) {
        throw Exception("ESP32 data characteristic not found");
      }

      // Enable notifications for data reception
      await _dataCharacteristic!.setNotifyValue(true);
      
      // Listen for data
      _dataSubscription = _dataCharacteristic!.lastValueStream.listen((data) {
        _handleReceivedData(data);
      });

      debugPrint("ESP32 services and characteristics configured successfully");
    } catch (e) {
      debugPrint("Error discovering services: $e");
      throw e;
    }
  }

  /// Handle received data from ESP32
  void _handleReceivedData(List<int> data) {
    try {
      // Convert bytes to string
      final jsonString = utf8.decode(data);
      debugPrint("Received data: $jsonString");

      // Parse JSON data
      final jsonData = json.decode(jsonString);
      final esp32Data = ESP32Data.fromJson(jsonData);

      // Emit data to listeners
      _dataController.add(esp32Data);
    } catch (e) {
      debugPrint("Error parsing received data: $e");
    }
  }

  /// Send command to ESP32
  Future<bool> sendCommand(String command) async {
    if (_dataCharacteristic == null) {
      debugPrint("Not connected to ESP32 device");
      return false;
    }

    try {
      final commandBytes = utf8.encode(command);
      await _dataCharacteristic!.write(commandBytes);
      debugPrint("Sent command to ESP32: $command");
      return true;
    } catch (e) {
      debugPrint("Error sending command to ESP32: $e");
      return false;
    }
  }

  /// Request color sensor data
  Future<bool> requestColorData() async {
    return await sendCommand('{"command":"get_color"}');
  }

  /// Request distance sensor data
  Future<bool> requestDistanceData() async {
    return await sendCommand('{"command":"get_distance"}');
  }

  /// Request GPS data
  Future<bool> requestGPSData() async {
    return await sendCommand('{"command":"get_gps"}');
  }

  /// Request all sensor data
  Future<bool> requestAllData() async {
    return await sendCommand('{"command":"get_all"}');
  }

  /// Handle disconnection
  void _handleDisconnection() {
    debugPrint("ESP32 device disconnected");
    _connectedDevice = null;
    _dataCharacteristic = null;
    _dataSubscription?.cancel();
    _dataSubscription = null;
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      
      // Cancel subscriptions
      _connectionSubscription?.cancel();
      _dataSubscription?.cancel();
      
      // Reset state
      _connectedDevice = null;
      _dataCharacteristic = null;
      _connectionSubscription = null;
      _dataSubscription = null;

      debugPrint("Disconnected from ESP32 device");
    } catch (e) {
      debugPrint("Error disconnecting: $e");
    }
  }

  /// Get list of paired devices
  Future<List<fbp.BluetoothDevice>> getPairedDevices() async {
    try {
      return await fbp.FlutterBluePlus.bondedDevices;
    } catch (e) {
      debugPrint("Error getting paired devices: $e");
      return [];
    }
  }

  /// Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    try {
      final state = await fbp.FlutterBluePlus.adapterState.first;
      return state == fbp.BluetoothAdapterState.on;
    } catch (e) {
      debugPrint("Error checking Bluetooth state: $e");
      return false;
    }
  }

  /// Turn on Bluetooth (Android only)
  Future<void> turnOnBluetooth() async {
    try {
      await fbp.FlutterBluePlus.turnOn();
    } catch (e) {
      debugPrint("Error turning on Bluetooth: $e");
    }
  }

  /// Dispose of the service
  void dispose() {
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    _connectionStateController.close();
    _dataController.close();
    _devicesController.close();
    disconnect();
  }
}

/// Data model for ESP32 sensor data
class ESP32Data {
  final ColorData? colorData;
  final DistanceData? distanceData;
  final GPSData? gpsData;
  final DateTime timestamp;
  final String deviceId;

  ESP32Data({
    this.colorData,
    this.distanceData,
    this.gpsData,
    required this.timestamp,
    required this.deviceId,
  });

  factory ESP32Data.fromJson(Map<String, dynamic> json) {
    return ESP32Data(
      colorData: json['color'] != null ? ColorData.fromJson(json['color']) : null,
      distanceData: json['distance'] != null ? DistanceData.fromJson(json['distance']) : null,
      gpsData: json['gps'] != null ? GPSData.fromJson(json['gps']) : null,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      deviceId: json['device_id'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': colorData?.toJson(),
      'distance': distanceData?.toJson(),
      'gps': gpsData?.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'device_id': deviceId,
    };
  }
}

/// Color sensor data
class ColorData {
  final int red;
  final int green;
  final int blue;
  final String? colorName;
  final double confidence;

  ColorData({
    required this.red,
    required this.green,
    required this.blue,
    this.colorName,
    required this.confidence,
  });

  factory ColorData.fromJson(Map<String, dynamic> json) {
    return ColorData(
      red: json['r'] ?? 0,
      green: json['g'] ?? 0,
      blue: json['b'] ?? 0,
      colorName: json['color_name'],
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'r': red,
      'g': green,
      'b': blue,
      'color_name': colorName,
      'confidence': confidence,
    };
  }

  /// Get RGB as Flutter Color
  Color get color => Color.fromARGB(255, red, green, blue);

  /// Get RGB as hex string
  String get hexColor => '#${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

/// Distance sensor data
class DistanceData {
  final double distance; // in centimeters
  final bool isObjectDetected;
  final String unit;

  DistanceData({
    required this.distance,
    required this.isObjectDetected,
    this.unit = 'cm',
  });

  factory DistanceData.fromJson(Map<String, dynamic> json) {
    return DistanceData(
      distance: (json['distance'] ?? 0.0).toDouble(),
      isObjectDetected: json['object_detected'] ?? false,
      unit: json['unit'] ?? 'cm',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'object_detected': isObjectDetected,
      'unit': unit,
    };
  }

  /// Check if object is within warning range
  bool get isWarningRange => distance < AppConstants.distanceClose;
  
  /// Check if object is within danger range
  bool get isDangerRange => distance < AppConstants.distanceVeryClose;
}

/// GPS data
class GPSData {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final String? address;

  GPSData({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.address,
  });

  factory GPSData.fromJson(Map<String, dynamic> json) {
    return GPSData(
      latitude: (json['lat'] ?? 0.0).toDouble(),
      longitude: (json['lng'] ?? 0.0).toDouble(),
      altitude: json['alt']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      speed: json['speed']?.toDouble(),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
      'alt': altitude,
      'accuracy': accuracy,
      'speed': speed,
      'address': address,
    };
  }

  /// Get coordinates as a formatted string
  String get coordinatesString => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}
