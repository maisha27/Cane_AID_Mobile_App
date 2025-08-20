import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for converting RGB values to color names
/// Provides both offline and online color detection capabilities
class ColorApiService {
  static const String _apiUrl = 'https://www.thecolorapi.com/id';
  static const Duration _requestTimeout = Duration(seconds: 5);

  /// Get color name from RGB values using external API
  /// Falls back to offline detection if API is unavailable
  static Future<ColorResult> getColorName(int red, int green, int blue) async {
    try {
      // Try online API first
      final apiResult = await _getColorFromApi(red, green, blue);
      if (apiResult != null) {
        return apiResult;
      }
    } catch (e) {
      debugPrint('Color API error: $e');
    }

    // Fallback to offline detection
    return _getColorOffline(red, green, blue);
  }

  /// Get color name from external API
  static Future<ColorResult?> _getColorFromApi(int red, int green, int blue) async {
    try {
      final rgbHex = _rgbToHex(red, green, blue);
      final url = Uri.parse('$_apiUrl?hex=$rgbHex');

      final response = await http.get(url).timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        return ColorResult(
          name: data['name']['value'] ?? 'Unknown',
          hex: data['hex']['value'] ?? rgbHex,
          rgb: 'RGB($red, $green, $blue)',
          source: ColorSource.api,
          confidence: 1.0,
        );
      }
    } catch (e) {
      debugPrint('API request failed: $e');
    }

    return null;
  }

  /// Offline color detection with enhanced color database
  static ColorResult _getColorOffline(int red, int green, int blue) {
    final colorName = _detectColorOffline(red, green, blue);
    final hex = _rgbToHex(red, green, blue);
    final confidence = _calculateConfidence(red, green, blue, colorName);

    return ColorResult(
      name: colorName,
      hex: hex,
      rgb: 'RGB($red, $green, $blue)',
      source: ColorSource.offline,
      confidence: confidence,
    );
  }

  /// Enhanced offline color detection algorithm
  static String _detectColorOffline(int red, int green, int blue) {
    // Calculate color properties
    final brightness = (red + green + blue) / 3;
    final saturation = _calculateSaturation(red, green, blue);
    final dominantChannel = _getDominantChannel(red, green, blue);
    
    // Very dark colors
    if (brightness < 30) {
      return 'Black';
    }
    
    // Very light colors
    if (brightness > 220) {
      if (saturation < 0.1) return 'White';
      if (red > 240 && green > 220 && blue > 220) return 'Off White';
      if (dominantChannel == 'red') return 'Light Pink';
      if (dominantChannel == 'green') return 'Light Green';
      if (dominantChannel == 'blue') return 'Light Blue';
      return 'Light';
    }
    
    // Gray scale colors
    if (saturation < 0.2) {
      if (brightness < 80) return 'Dark Gray';
      if (brightness < 140) return 'Gray';
      if (brightness < 180) return 'Light Gray';
      return 'Silver';
    }
    
    // Color detection based on dominant channels
    return _getColorByDominantChannels(red, green, blue, brightness, saturation);
  }

  /// Get color name based on dominant color channels
  static String _getColorByDominantChannels(int red, int green, int blue, double brightness, double saturation) {
    // Single dominant color
    if (red > green + 30 && red > blue + 30) {
      if (brightness > 180) return 'Light Red';
      if (brightness > 120) return 'Red';
      if (brightness > 60) return 'Dark Red';
      return 'Maroon';
    }
    
    if (green > red + 30 && green > blue + 30) {
      if (brightness > 180) return 'Light Green';
      if (brightness > 120) return 'Green';
      if (brightness > 60) return 'Dark Green';
      return 'Forest Green';
    }
    
    if (blue > red + 30 && blue > green + 30) {
      if (brightness > 180) return 'Light Blue';
      if (brightness > 120) return 'Blue';
      if (brightness > 60) return 'Dark Blue';
      return 'Navy';
    }
    
    // Two dominant colors (mixed colors)
    if (red > 100 && green > 100 && blue < 80) {
      if (red > green + 30) return 'Orange';
      if (green > red + 30) return 'Lime';
      return 'Yellow';
    }
    
    if (red > 100 && blue > 100 && green < 80) {
      if (red > blue + 30) return 'Hot Pink';
      if (blue > red + 30) return 'Purple';
      return 'Magenta';
    }
    
    if (green > 100 && blue > 100 && red < 80) {
      if (green > blue + 30) return 'Aqua';
      if (blue > green + 30) return 'Teal';
      return 'Cyan';
    }
    
    // All channels relatively high
    if (red > 80 && green > 80 && blue > 80) {
      if (saturation > 0.6) return 'Colorful';
      return 'Beige';
    }
    
    // Brownish colors
    if (red > green && green > blue && red > 80) {
      if (brightness > 120) return 'Brown';
      return 'Dark Brown';
    }
    
    return 'Mixed Color';
  }

  /// Calculate color saturation
  static double _calculateSaturation(int red, int green, int blue) {
    final max = [red, green, blue].reduce((a, b) => a > b ? a : b);
    final min = [red, green, blue].reduce((a, b) => a < b ? a : b);
    
    if (max == 0) return 0.0;
    return (max - min) / max;
  }

  /// Get dominant color channel
  static String _getDominantChannel(int red, int green, int blue) {
    if (red >= green && red >= blue) return 'red';
    if (green >= red && green >= blue) return 'green';
    return 'blue';
  }

  /// Calculate confidence based on color clarity
  static double _calculateConfidence(int red, int green, int blue, String colorName) {
    final saturation = _calculateSaturation(red, green, blue);
    final brightness = (red + green + blue) / 3;
    
    // Higher confidence for well-defined colors
    if (colorName.contains('Black') || colorName.contains('White')) {
      return brightness < 30 || brightness > 220 ? 0.9 : 0.7;
    }
    
    if (colorName.contains('Gray')) {
      return saturation < 0.2 ? 0.8 : 0.6;
    }
    
    // Primary colors have higher confidence
    if (['Red', 'Green', 'Blue', 'Yellow', 'Purple', 'Orange'].any((color) => colorName.contains(color))) {
      return saturation > 0.5 ? 0.85 : 0.7;
    }
    
    return 0.6; // Default confidence for mixed colors
  }

  /// Convert RGB to hex string
  static String _rgbToHex(int red, int green, int blue) {
    return '#${red.toRadixString(16).padLeft(2, '0')}'
           '${green.toRadixString(16).padLeft(2, '0')}'
           '${blue.toRadixString(16).padLeft(2, '0')}';
  }
}

/// Color detection result with metadata
class ColorResult {
  final String name;
  final String hex;
  final String rgb;
  final ColorSource source;
  final double confidence;

  ColorResult({
    required this.name,
    required this.hex,
    required this.rgb,
    required this.source,
    required this.confidence,
  });

  @override
  String toString() {
    return 'ColorResult(name: $name, hex: $hex, rgb: $rgb, source: $source, confidence: $confidence)';
  }
}

/// Source of color detection
enum ColorSource {
  api,    // External API
  offline // Local algorithm
}

/// Extension for debugging
extension ColorSourceExtension on ColorSource {
  String get displayName {
    switch (this) {
      case ColorSource.api:
        return 'Online API';
      case ColorSource.offline:
        return 'Offline Detection';
    }
  }
}
