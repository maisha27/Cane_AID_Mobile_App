import 'dart:convert';
import 'package:http/http.dart' as http;

/// Geocoding service for converting GPS coordinates to place names
/// Uses OpenStreetMap Nominatim API (free, no API key required)
class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const Duration _timeout = Duration(seconds: 10);

  /// Convert latitude and longitude to a readable place name
  /// Returns a formatted address string or error message
  static Future<GeocodingResult> getPlaceName(double latitude, double longitude) async {
    try {
      // Validate coordinates
      if (!_isValidCoordinate(latitude, longitude)) {
        return GeocodingResult.error('Invalid coordinates');
      }

      // Build the API URL
      final url = Uri.parse(
        '$_baseUrl/reverse?format=json&lat=$latitude&lon=$longitude&addressdetails=1&accept-language=en'
      );

      // Make the HTTP request
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'CaneAID-Flutter-App/1.0',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        if (data.containsKey('display_name')) {
          final displayName = data['display_name'] as String;
          final address = data['address'] as Map<String, dynamic>?;
          
          // Extract key location components
          final formattedPlace = _formatPlaceName(displayName, address);
          
          return GeocodingResult.success(
            placeName: formattedPlace,
            fullAddress: displayName,
            coordinates: '$latitude°N, $longitude°E',
          );
        } else {
          return GeocodingResult.error('Location not found');
        }
      } else {
        return GeocodingResult.error('Failed to fetch location data');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return GeocodingResult.error('Request timeout');
      } else {
        return GeocodingResult.error('Network error: ${e.toString()}');
      }
    }
  }

  /// Validate if coordinates are within valid ranges
  static bool _isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
  }

  /// Format the place name to be more readable
  static String _formatPlaceName(String displayName, Map<String, dynamic>? address) {
    if (address == null) {
      // If no detailed address, return simplified display name
      final parts = displayName.split(', ');
      if (parts.length > 2) {
        return '${parts[0]}, ${parts[parts.length - 1]}'; // First part + country
      }
      return displayName;
    }

    // Build formatted name from address components
    final List<String> nameParts = [];
    
    // Add road/building if available
    if (address['road'] != null) {
      nameParts.add(address['road']);
    } else if (address['building'] != null) {
      nameParts.add(address['building']);
    }
    
    // Add city/town/village
    final city = address['city'] ?? address['town'] ?? address['village'] ?? address['suburb'];
    if (city != null) {
      nameParts.add(city);
    }
    
    // Add country
    if (address['country'] != null) {
      nameParts.add(address['country']);
    }
    
    // Return formatted name or fallback to display name
    return nameParts.isNotEmpty ? nameParts.join(', ') : displayName;
  }
}

/// Result class for geocoding operations
class GeocodingResult {
  final bool isSuccess;
  final String? placeName;
  final String? fullAddress;
  final String? coordinates;
  final String? error;

  const GeocodingResult._({
    required this.isSuccess,
    this.placeName,
    this.fullAddress,
    this.coordinates,
    this.error,
  });

  factory GeocodingResult.success({
    required String placeName,
    required String fullAddress,
    required String coordinates,
  }) {
    return GeocodingResult._(
      isSuccess: true,
      placeName: placeName,
      fullAddress: fullAddress,
      coordinates: coordinates,
    );
  }

  factory GeocodingResult.error(String errorMessage) {
    return GeocodingResult._(
      isSuccess: false,
      error: errorMessage,
    );
  }
}
