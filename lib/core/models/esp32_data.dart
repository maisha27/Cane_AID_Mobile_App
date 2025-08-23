/// Data models for ESP32 sensor data
///
/// This file contains all the data structures used to represent
/// sensor data received from the ESP32 device.

import 'package:flutter/foundation.dart';
// Import math library at the top
import 'dart:math' as dart_math;

/// Main ESP32 data container
class ESP32Data {
  final DateTime timestamp;
  final ColorData? colorData;
  final DistanceData? distanceData;
  final GPSData? gpsData;
  final String? rawJson;

  ESP32Data({
    required this.timestamp,
    this.colorData,
    this.distanceData,
    this.gpsData,
    this.rawJson,
  });

  /// Create ESP32Data from JSON map
  factory ESP32Data.fromJson(Map<String, dynamic> json) {
    return ESP32Data(
      timestamp: DateTime.now(),
      colorData: _hasColorData(json) ? ColorData.fromJson(json) : null,
      distanceData:
          json.containsKey('distance') ? DistanceData.fromJson(json) : null,
      gpsData: _hasGPSData(json) ? GPSData.fromJson(json) : null,
      rawJson: json.toString(),
    );
  }

  /// Check if JSON contains color data
  static bool _hasColorData(Map<String, dynamic> json) {
    return json.containsKey('r') &&
        json.containsKey('g') &&
        json.containsKey('b');
  }

  /// Check if JSON contains GPS data
  static bool _hasGPSData(Map<String, dynamic> json) {
    return json.containsKey('latitude') && json.containsKey('longitude');
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'timestamp': timestamp.toIso8601String(),
    };

    if (colorData != null) {
      json.addAll(colorData!.toJson());
    }

    if (distanceData != null) {
      json.addAll(distanceData!.toJson());
    }

    if (gpsData != null) {
      json.addAll(gpsData!.toJson());
    }

    return json;
  }

  /// Check if any sensor data is available
  bool get hasData =>
      colorData != null || distanceData != null || gpsData != null;

  /// Get a summary string of available data
  String get dataSummary {
    List<String> parts = [];

    if (distanceData != null) {
      parts.add('Distance: ${distanceData!.distance.toStringAsFixed(1)}cm');
    }

    if (colorData != null) {
      if (colorData!.colorName != null) {
        parts.add('Color: ${colorData!.colorName}');
      } else {
        parts.add('RGB: (${colorData!.r}, ${colorData!.g}, ${colorData!.b})');
      }
    }

    if (gpsData != null) {
      parts.add('GPS: ${gpsData!.coordinatesString}');
    }

    return parts.isNotEmpty ? parts.join(' | ') : 'No data';
  }

  @override
  String toString() {
    return 'ESP32Data{timestamp: $timestamp, hasColor: ${colorData != null}, hasDistance: ${distanceData != null}, hasGPS: ${gpsData != null}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ESP32Data &&
        other.timestamp == timestamp &&
        other.colorData == colorData &&
        other.distanceData == distanceData &&
        other.gpsData == gpsData;
  }

  @override
  int get hashCode {
    return Object.hash(timestamp, colorData, distanceData, gpsData);
  }
}

/// Color sensor data
class ColorData {
  final int r;
  final int g;
  final int b;
  final String? colorName;
  final double? brightness;
  final String? hexColor;

  ColorData({
    required this.r,
    required this.g,
    required this.b,
    this.colorName,
    this.brightness,
    this.hexColor,
  });

  /// Create ColorData from JSON
  factory ColorData.fromJson(Map<String, dynamic> json) {
    final r = (json['r'] as num?)?.toInt() ?? 0;
    final g = (json['g'] as num?)?.toInt() ?? 0;
    final b = (json['b'] as num?)?.toInt() ?? 0;

    return ColorData(
      r: r,
      g: g,
      b: b,
      colorName: json['color_name'] as String? ?? json['colorName'] as String?,
      brightness: (json['brightness'] as num?)?.toDouble(),
      hexColor: json['hex_color'] as String? ?? json['hexColor'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'r': r, 'g': g, 'b': b};

    if (colorName != null) json['colorName'] = colorName;
    if (brightness != null) json['brightness'] = brightness;
    if (hexColor != null) json['hexColor'] = hexColor;

    return json;
  }

  /// Get hex color string
  String get hexColorString {
    if (hexColor != null) return hexColor!;
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// Calculate brightness (0.0 to 1.0)
  double get calculatedBrightness {
    if (brightness != null) return brightness!;
    return (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
  }

  /// Determine if color is dark
  bool get isDark => calculatedBrightness < 0.5;

  /// Get RGB string representation
  String get rgbString => 'RGB($r, $g, $b)';

  /// Determine basic color name if not provided
  String get determinedColorName {
    if (colorName != null) return colorName!;

    // Simple color name determination
    if (r > 200 && g > 200 && b > 200) return 'White';
    if (r < 50 && g < 50 && b < 50) return 'Black';
    if (r > 150 && g < 100 && b < 100) return 'Red';
    if (r < 100 && g > 150 && b < 100) return 'Green';
    if (r < 100 && g < 100 && b > 150) return 'Blue';
    if (r > 150 && g > 150 && b < 100) return 'Yellow';
    if (r > 150 && g < 100 && b > 150) return 'Magenta';
    if (r < 100 && g > 150 && b > 150) return 'Cyan';
    if (r > 150 && g > 100 && b < 100) return 'Orange';
    if (r > 100 && g < 150 && b > 100) return 'Purple';

    return 'Unknown';
  }

  @override
  String toString() {
    return 'ColorData{r: $r, g: $g, b: $b, colorName: ${colorName ?? determinedColorName}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorData &&
        other.r == r &&
        other.g == g &&
        other.b == b &&
        other.colorName == colorName;
  }

  @override
  int get hashCode => Object.hash(r, g, b, colorName);
}

/// Distance sensor data
class DistanceData {
  final double distance; // in centimeters
  final String unit;
  final double? accuracy;
  final DistanceLevel level;

  DistanceData({
    required this.distance,
    this.unit = 'cm',
    this.accuracy,
    DistanceLevel? level,
  }) : level = level ?? _determineDistanceLevel(distance);

  /// Create DistanceData from JSON
  factory DistanceData.fromJson(Map<String, dynamic> json) {
    final distance = (json['distance'] as num?)?.toDouble() ?? 0.0;

    return DistanceData(
      distance: distance,
      unit: json['unit'] as String? ?? 'cm',
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'distance': distance,
      'unit': unit,
      'level': level.toString(),
    };

    if (accuracy != null) json['accuracy'] = accuracy;

    return json;
  }

  /// Determine distance level based on distance value
  static DistanceLevel _determineDistanceLevel(double distance) {
    if (distance < 20) return DistanceLevel.veryClose;
    if (distance < 50) return DistanceLevel.close;
    if (distance < 100) return DistanceLevel.medium;
    if (distance < 200) return DistanceLevel.far;
    return DistanceLevel.veryFar;
  }

  /// Get distance description
  String get description {
    switch (level) {
      case DistanceLevel.veryClose:
        return 'Very Close';
      case DistanceLevel.close:
        return 'Close';
      case DistanceLevel.medium:
        return 'Medium';
      case DistanceLevel.far:
        return 'Far';
      case DistanceLevel.veryFar:
        return 'Very Far';
    }
  }

  /// Get formatted distance string
  String get formattedDistance => '${distance.toStringAsFixed(1)} $unit';

  /// Check if distance indicates potential obstacle
  bool get isObstacle =>
      level == DistanceLevel.veryClose || level == DistanceLevel.close;

  /// Check if distance is safe
  bool get isSafe =>
      level == DistanceLevel.far || level == DistanceLevel.veryFar;

  @override
  String toString() {
    return 'DistanceData{distance: $distance $unit, level: $level}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DistanceData &&
        other.distance == distance &&
        other.unit == unit &&
        other.level == level;
  }

  @override
  int get hashCode => Object.hash(distance, unit, level);
}

/// Distance levels for categorizing proximity
enum DistanceLevel { veryClose, close, medium, far, veryFar }

/// GPS location data
class GPSData {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final String? address;
  final DateTime timestamp;

  GPSData({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.address,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create GPSData from JSON
  factory GPSData.fromJson(Map<String, dynamic> json) {
    return GPSData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      altitude: (json['altitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      address: json['address'] as String?,
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'] as String)
              : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };

    if (altitude != null) json['altitude'] = altitude;
    if (accuracy != null) json['accuracy'] = accuracy;
    if (address != null) json['address'] = address;

    return json;
  }

  /// Get coordinates as a formatted string
  String get coordinatesString =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  /// Get coordinates with altitude if available
  String get fullCoordinatesString {
    String coords = coordinatesString;
    if (altitude != null) {
      coords += ', ${altitude!.toStringAsFixed(1)}m';
    }
    return coords;
  }

  /// Check if GPS data is valid
  bool get isValid => latitude != 0.0 || longitude != 0.0;

  /// Get display address or coordinates
  String get displayLocation => address ?? coordinatesString;

  /// Calculate distance to another GPS point (in kilometers)
  double distanceTo(GPSData other) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double lat1Rad = latitude * (3.14159 / 180);
    double lat2Rad = other.latitude * (3.14159 / 180);
    double deltaLatRad = (other.latitude - latitude) * (3.14159 / 180);
    double deltaLonRad = (other.longitude - longitude) * (3.14159 / 180);

    double a =
        (deltaLatRad / 2) * (deltaLatRad / 2) +
        (lat1Rad.cos()) *
            (lat2Rad.cos()) *
            (deltaLonRad / 2) *
            (deltaLonRad / 2);
    double c = 2 * (a.sqrt()).asin();

    return earthRadius * c;
  }

  @override
  String toString() {
    return 'GPSData{lat: $latitude, lng: $longitude, address: ${address ?? 'N/A'}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GPSData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, address);
}

/// Extension methods for numeric calculations
extension DoubleExtensions on double {
  double sin() => dart_math.sin(this);
  double cos() => dart_math.cos(this);
  double asin() => dart_math.asin(this);
  double sqrt() => dart_math.sqrt(this);
}
