/// Data models for ESP32 sensor data
///
/// This file contains the simplified data structure used to represent
/// sensor data received from the ESP32 device via WebSocket.
/// 
/// Matches the simple JSON structure: {"r": 255, "g": 128, "b": 64, "distance": 50, "latitude": 23.7808, "longitude": 90.2792}

/// Main ESP32 data container - simplified structure matching sample WebSocket code
class ESP32Data {
  final DateTime timestamp;
  final int r;
  final int g;
  final int b;
  final double distance;
  final double latitude;
  final double longitude;
  final String? colorName;
  final String? rawJson;

  ESP32Data({
    required this.timestamp,
    required this.r,
    required this.g,
    required this.b,
    required this.distance,
    required this.latitude,
    required this.longitude,
    this.colorName,
    this.rawJson,
  });

  /// Create ESP32Data from JSON map - matches sample WebSocket structure
  factory ESP32Data.fromJson(Map<String, dynamic> json) {
    return ESP32Data(
      timestamp: DateTime.now(),
      r: (json['r'] as num?)?.toInt() ?? 0,
      g: (json['g'] as num?)?.toInt() ?? 0,
      b: (json['b'] as num?)?.toInt() ?? 0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      colorName: _determineColorName(
        (json['r'] as num?)?.toInt() ?? 0,
        (json['g'] as num?)?.toInt() ?? 0,
        (json['b'] as num?)?.toInt() ?? 0,
      ),
      rawJson: json.toString(),
    );
  }

  /// Determine basic color name from RGB values
  static String _determineColorName(int r, int g, int b) {
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

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'r': r,
      'g': g,
      'b': b,
      'distance': distance,
      'latitude': latitude,
      'longitude': longitude,
      'colorName': colorName,
    };
  }

  /// Check if any sensor data is available
  bool get hasData => true; // Always has data with this simple structure

  /// Get a summary string of available data
  String get dataSummary {
    List<String> parts = [];
    parts.add('Distance: ${distance.toStringAsFixed(1)}cm');
    parts.add('Color: ${colorName ?? "RGB($r, $g, $b)"}');
    parts.add('GPS: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}');
    return parts.join(' | ');
  }

  /// Get hex color string
  String get hexColor {
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// Get RGB string representation
  String get rgbString => 'RGB($r, $g, $b)';

  /// Get coordinates string
  String get coordinatesString => '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  /// Determine if distance indicates potential obstacle
  bool get isObstacle => distance < 50.0;

  /// Check if distance is safe
  bool get isSafe => distance > 100.0;

  /// Get distance level description
  String get distanceDescription {
    if (distance < 20) return 'Very Close';
    if (distance < 50) return 'Close';
    if (distance < 100) return 'Medium';
    if (distance < 200) return 'Far';
    return 'Very Far';
  }

  /// Calculate brightness (0.0 to 1.0)
  double get brightness {
    return (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
  }

  /// Determine if color is dark
  bool get isDark => brightness < 0.5;

  @override
  String toString() {
    return 'ESP32Data{timestamp: $timestamp, RGB: ($r, $g, $b), distance: ${distance}cm, GPS: ($latitude, $longitude)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ESP32Data &&
        other.timestamp == timestamp &&
        other.r == r &&
        other.g == g &&
        other.b == b &&
        other.distance == distance &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(timestamp, r, g, b, distance, latitude, longitude);
  }
}
