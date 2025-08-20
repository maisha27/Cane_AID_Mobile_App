// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cane AID';

  @override
  String get homeScreen => 'Home Screen';

  @override
  String get welcomeMessage => 'Welcome to Cane AID';

  @override
  String get welcomeSubtitle => 'Your assistive companion for daily navigation';

  @override
  String get colorDetection => 'Color Detection';

  @override
  String get colorDetectionSubtitle => 'Identify colors around you';

  @override
  String get colorDetectionScreen => 'Color Detection Screen';

  @override
  String get detectedColor => 'Detected Color';

  @override
  String get startDetection => 'Start Detection';

  @override
  String get stopDetection => 'Stop Detection';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get colorHistory => 'Color History';

  @override
  String get noColorDetected => 'No color detected';

  @override
  String get tapStartDetection =>
      'Tap start detection to identify colors around you';

  @override
  String get distanceDetection => 'Distance Detection';

  @override
  String get distanceDetectionSubtitle => 'Detect nearby objects';

  @override
  String get locationServices => 'Location Services';

  @override
  String get locationServicesSubtitle => 'Share your location';

  @override
  String get deviceConnection => 'Device Connection';

  @override
  String get deviceConnectionSubtitle => 'Connect to ESP32';

  @override
  String get bluetoothConnection => 'Bluetooth Connection';

  @override
  String get bluetoothConnectionScreen => 'Bluetooth Connection Screen';

  @override
  String get connectionStatus => 'Connection Status';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get scan => 'Scan';

  @override
  String get stop => 'Stop';

  @override
  String get scanning => 'Scanning...';

  @override
  String get scanningForDevices => 'Scanning for ESP32 devices';

  @override
  String get stopScanning => 'Stop scanning for devices';

  @override
  String get discoveredDevices => 'Discovered Devices';

  @override
  String get pairedDevices => 'Paired Devices';

  @override
  String get noDevicesFound => 'No ESP32 devices found';

  @override
  String get noDevicesFoundSubtitle =>
      'Make sure your device is powered on and in pairing mode';

  @override
  String get noPairedDevices => 'No paired ESP32 devices';

  @override
  String get connectToDevice => 'Connect to your ESP32 Cane AID device';

  @override
  String get settings => 'Settings';

  @override
  String get help => 'Help';

  @override
  String get tutorial => 'Tutorial';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get bangla => 'বাংলা';

  @override
  String get bluetoothDisabled => 'Bluetooth Disabled';

  @override
  String get bluetoothDisabledMessage =>
      'Please enable Bluetooth to connect to your ESP32 device.';

  @override
  String get cancel => 'Cancel';

  @override
  String get enable => 'Enable';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';
}
