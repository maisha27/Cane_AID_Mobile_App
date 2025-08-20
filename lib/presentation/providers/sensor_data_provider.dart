import 'package:flutter/foundation.dart';

class SensorDataProvider with ChangeNotifier {
  int _r = 0;
  int _g = 0;
  int _b = 0;
  double _distance = 0.0;
  double _latitude = 0.0;
  double _longitude = 0.0;

  // Getters
  int get r => _r;
  int get g => _g;
  int get b => _b;
  double get distance => _distance;
  double get latitude => _latitude;
  double get longitude => _longitude;

  void updateSensorData({
    required int r,
    required int g,
    required int b,
    required double distance,
    required double latitude,
    required double longitude,
  }) {
    _r = r;
    _g = g;
    _b = b;
    _distance = distance;
    _latitude = latitude;
    _longitude = longitude;
    notifyListeners();
  }
}
