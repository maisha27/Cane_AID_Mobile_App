# Bluetooth and Color Detection Mechanism

## Overall Architecture

```
ESP32 CAM Device ←→ Bluetooth ←→ Flutter App ←→ User Interface
     ↓                                ↓              ↓
Color Sensor                    Color API        Voice Output
Distance Sensor              Color Processing   Bengali/English
GPS Module                   Distance Alert     Haptic Feedback
```

## Bluetooth Communication Mechanism

### 1. **ESP32 Side (Hardware)**
```c
// ESP32 sends JSON data via Bluetooth Serial
{
  "type": "color",
  "r": 255,
  "g": 128,
  "b": 64,
  "timestamp": 1640995200
}

{
  "type": "distance", 
  "distance": 45.5,
  "unit": "cm",
  "timestamp": 1640995201
}

{
  "type": "gps",
  "latitude": 23.8103,
  "longitude": 90.4125,
  "timestamp": 1640995202
}
```

### 2. **Flutter App Side (Software)**
```dart
// BluetoothProvider listens to data stream
bluetoothProvider.dataStream.listen((esp32Data) {
  if (esp32Data.colorData != null) {
    _processColorData(esp32Data.colorData!);
  }
  if (esp32Data.distanceData != null) {
    _processDistanceData(esp32Data.distanceData!);
  }
});
```

## Color Detection Workflow

### Step-by-Step Process:

1. **User Opens Color Detection Screen**
   - TTS announces: "Color Detection screen" / "রঙ শনাক্তকরণ স্ক্রিন"
   - Shows current connection status with ESP32

2. **User Taps "Start Detection"**
   - App sends command to ESP32: `{"command": "start_color_detection"}`
   - ESP32 starts reading RGB values from color sensor continuously
   - TTS announces: "Color detection started" / "রঙ শনাক্তকরণ শুরু হয়েছে"

3. **Real-time Color Processing**
   ```
   ESP32 Color Sensor → RGB Values (255, 128, 64)
   ↓
   Bluetooth Transmission → Flutter App receives JSON
   ↓
   Color API Processing → "Orange" / "কমলা"
   ↓
   TTS Announcement → "Detected color: Orange" / "শনাক্তকৃত রঙ: কমলা"
   ↓
   UI Update → Color circle shows orange, history updated
   ```

4. **Color API Service**
   - **Online Mode**: Sends RGB to TheColorAPI.com → Gets precise color name
   - **Offline Mode**: Uses built-in algorithm with 60+ color definitions
   - **Confidence Scoring**: Ensures accurate color matching

5. **User Interface Updates**
   - Color circle changes to detected color
   - Color name displayed in current language
   - History list updated with timestamp
   - Haptic feedback on detection

## Bluetooth Connection Workflow

### Connection Process:

1. **Bluetooth Initialization**
   ```dart
   // App checks Bluetooth availability
   final isEnabled = await BluetoothProvider.isBluetoothEnabled();
   if (!isEnabled) {
     // Show enable Bluetooth dialog
   }
   ```

2. **Device Discovery**
   - User taps "Scan" button
   - App scans for devices named "ESP32" or "CaneAID"
   - Discovered devices appear in list with signal strength

3. **Connection Establishment**
   ```dart
   // User taps on ESP32 device
   final success = await bluetoothProvider.connectToDevice(device);
   if (success) {
     // TTS: "Connected to ESP32" / "ESP32 এর সাথে সংযুক্ত"
     // Start listening for data
   }
   ```

4. **Data Stream Management**
   ```dart
   // Continuous data listening
   device.characteristicRead.listen((data) {
     final jsonString = utf8.decode(data);
     final esp32Data = ESP32Data.fromJson(jsonDecode(jsonString));
     _processIncomingData(esp32Data);
   });
   ```

## ESP32 Hardware Configuration

### Required Components:
1. **ESP32 CAM Module** - Main microcontroller with Bluetooth
2. **RGB Color Sensor** (TCS3200/TCS34725) - For color detection
3. **Ultrasonic Sensor** (HC-SR04) - For distance measurement
4. **GPS Module** (NEO-6M/8M) - For location tracking
5. **Power Management** - Battery pack with voltage regulation

### ESP32 Code Structure:
```c
#include "BluetoothSerial.h"
#include <ArduinoJson.h>

BluetoothSerial SerialBT;

void setup() {
  SerialBT.begin("CaneAID_ESP32");
  initializeSensors();
}

void loop() {
  if (colorDetectionActive) {
    readColorSensor();
    sendColorData();
  }
  
  if (distanceDetectionActive) {
    readDistanceSensor();
    sendDistanceData();
  }
  
  delay(500); // Send data every 500ms
}
```

## User Experience Flow

### For Visually Impaired Users:

1. **Voice Guidance**: Every action has TTS feedback
2. **Haptic Feedback**: Button presses and detections have vibration
3. **Semantic Labels**: Screen readers can navigate all elements
4. **Large Touch Targets**: Buttons are accessibility-sized
5. **Error Handling**: Clear voice announcements for issues

### Real-world Usage:
- Point phone camera at object
- ESP32 color sensor reads the surface color
- App announces color name in preferred language
- User gets immediate audio feedback
- History maintained for later reference

This system enables independent color identification for visually impaired users through voice output and haptic feedback, making daily tasks like clothing selection, object identification, and navigation much easier.
