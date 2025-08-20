import 'package:flutter/material.dart';

/// The translations for English (`en`).
class AppLocalizations {
  AppLocalizations(this.localeName);

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('bn'),
  ];

  // English translations
  String get appTitle => localeName == 'bn' ? 'কেন এইড' : 'Cane AID';
  String get homeScreen => localeName == 'bn' ? 'হোম স্ক্রিন' : 'Home Screen';
  String get welcomeMessage => localeName == 'bn' ? 'কেন এইড-এ স্বাগতম' : 'Welcome to Cane AID';
  String get welcomeSubtitle => localeName == 'bn' ? 'দৈনন্দিন নেভিগেশনের জন্য আপনার সহায়ক সঙ্গী' : 'Your assistive companion for daily navigation';
  
  String get colorDetection => localeName == 'bn' ? 'রঙ শনাক্তকরণ' : 'Color Detection';
  String get colorDetectionSubtitle => localeName == 'bn' ? 'আপনার চারপাশের রং চিহ্নিত করুন' : 'Identify colors around you';
  String get colorDetectionScreen => localeName == 'bn' ? 'রঙ শনাক্তকরণ স্ক্রিন' : 'Color Detection Screen';
  String get detectedColor => localeName == 'bn' ? 'শনাক্তকৃত রঙ' : 'Detected Color';
  String get startDetection => localeName == 'bn' ? 'শনাক্তকরণ শুরু করুন' : 'Start Detection';
  String get stopDetection => localeName == 'bn' ? 'শনাক্তকরণ বন্ধ করুন' : 'Stop Detection';
  String get clearHistory => localeName == 'bn' ? 'ইতিহাস মুছুন' : 'Clear History';
  String get colorHistory => localeName == 'bn' ? 'রঙের ইতিহাস' : 'Color History';
  String get noColorDetected => localeName == 'bn' ? 'কোন রঙ শনাক্ত হয়নি' : 'No color detected';
  String get tapStartDetection => localeName == 'bn' ? 'আপনার চারপাশের রং চিহ্নিত করতে শনাক্তকরণ শুরু করুন ট্যাপ করুন' : 'Tap start detection to identify colors around you';
  
  String get distanceDetection => localeName == 'bn' ? 'দূরত্ব শনাক্তকরণ' : 'Distance Detection';
  String get distanceDetectionSubtitle => localeName == 'bn' ? 'কাছাকাছি বস্তু শনাক্ত করুন' : 'Detect nearby objects';
  
  String get locationServices => localeName == 'bn' ? 'অবস্থান সেবা' : 'Location Services';
  String get locationServicesSubtitle => localeName == 'bn' ? 'আপনার অবস্থান শেয়ার করুন' : 'Share your location';
  
  String get deviceConnection => localeName == 'bn' ? 'ডিভাইস সংযোগ' : 'Device Connection';
  String get deviceConnectionSubtitle => localeName == 'bn' ? 'ESP32 এর সাথে সংযোগ করুন' : 'Connect to ESP32';
  String get bluetoothConnection => localeName == 'bn' ? 'ব্লুটুথ সংযোগ' : 'Bluetooth Connection';
  String get bluetoothConnectionScreen => localeName == 'bn' ? 'ব্লুটুথ সংযোগ স্ক্রিন' : 'Bluetooth Connection Screen';
  String get connectionStatus => localeName == 'bn' ? 'সংযোগের অবস্থা' : 'Connection Status';
  String get connected => localeName == 'bn' ? 'সংযুক্ত' : 'Connected';
  String get disconnected => localeName == 'bn' ? 'সংযোগ বিচ্ছিন্ন' : 'Disconnected';
  String get disconnect => localeName == 'bn' ? 'সংযোগ বিচ্ছিন্ন করুন' : 'Disconnect';
  String get scan => localeName == 'bn' ? 'স্ক্যান' : 'Scan';
  String get stop => localeName == 'bn' ? 'বন্ধ' : 'Stop';
  String get scanning => localeName == 'bn' ? 'স্ক্যান করা হচ্ছে...' : 'Scanning...';
  String get scanningForDevices => localeName == 'bn' ? 'ESP32 ডিভাইসের জন্য স্ক্যান করা হচ্ছে' : 'Scanning for ESP32 devices';
  String get stopScanning => localeName == 'bn' ? 'ডিভাইস স্ক্যান বন্ধ করুন' : 'Stop scanning for devices';
  String get discoveredDevices => localeName == 'bn' ? 'আবিষ্কৃত ডিভাইস' : 'Discovered Devices';
  String get pairedDevices => localeName == 'bn' ? 'যুগ্ম ডিভাইস' : 'Paired Devices';
  String get noDevicesFound => localeName == 'bn' ? 'কোন ESP32 ডিভাইস পাওয়া যায়নি' : 'No ESP32 devices found';
  String get noDevicesFoundSubtitle => localeName == 'bn' ? 'নিশ্চিত করুন যে আপনার ডিভাইস চালু আছে এবং পেয়ারিং মোডে আছে' : 'Make sure your device is powered on and in pairing mode';
  String get noPairedDevices => localeName == 'bn' ? 'কোন যুগ্ম ESP32 ডিভাইস নেই' : 'No paired ESP32 devices';
  String get connectToDevice => localeName == 'bn' ? 'আপনার ESP32 কেন এইড ডিভাইসের সাথে সংযোগ করুন' : 'Connect to your ESP32 Cane AID device';
  String get start => localeName == 'bn' ? 'শুরু করুন' : 'Start';
  String get clear => localeName == 'bn' ? 'মুছুন' : 'Clear';
  
  String get settings => localeName == 'bn' ? 'সেটিংস' : 'Settings';
  String get settingsScreen => localeName == 'bn' ? 'সেটিংস স্ক্রিন' : 'Settings Screen';
  String get configureAppPreferences => localeName == 'bn' ? 'অ্যাপের পছন্দ এবং অ্যাক্সেসিবিলিটি অপশন কনফিগার করুন' : 'Configure app preferences and accessibility options';
  String get help => localeName == 'bn' ? 'সাহায্য' : 'Help';
  String get tutorial => localeName == 'bn' ? 'টিউটোরিয়াল' : 'Tutorial';
  String get language => localeName == 'bn' ? 'ভাষা' : 'Language';
  String get languageSettings => localeName == 'bn' ? 'ভাষা সেটিংস' : 'Language Settings';
  String get chooseYourLanguage => localeName == 'bn' ? 'আপনার ভাষা বেছে নিন' : 'Choose your preferred language';
  String get english => 'English';
  String get bangla => 'বাংলা';
  
  // Settings sections and options
  String get generalSettings => localeName == 'bn' ? 'সাধারণ সেটিংস' : 'General Settings';
  String get accessibilityOptions => localeName == 'bn' ? 'অ্যাক্সেসিবিলিটি অপশন' : 'Accessibility Options';
  String get appPreferences => localeName == 'bn' ? 'অ্যাপের পছন্দ' : 'App Preferences';
  String get voiceSettings => localeName == 'bn' ? 'ভয়েস সেটিংস' : 'Voice Settings';
  String get voiceAndSpeech => localeName == 'bn' ? 'ভয়েস এবং স্পিচ সেটিংস' : 'Voice and speech settings';
  String get bluetoothSettings => localeName == 'bn' ? 'ব্লুটুথ সেটিংস' : 'Bluetooth Settings';
  String get esp32DeviceManagement => localeName == 'bn' ? 'ESP32 ডিভাইস ব্যবস্থাপনা' : 'ESP32 device management';
  String get emergencyContact => localeName == 'bn' ? 'জরুরি যোগাযোগ' : 'Emergency Contact';
  String get caretakerContact => localeName == 'bn' ? 'পরিচর্যাকারীর যোগাযোগ' : 'Caretaker Contact';
  String get emergencyContactInfo => localeName == 'bn' ? 'জরুরি যোগাযোগের তথ্য' : 'Emergency contact information';
  String get helpAndSupport => localeName == 'bn' ? 'সাহায্য এবং সহায়তা' : 'Help & Support';
  String get helpAndTutorial => localeName == 'bn' ? 'সাহায্য এবং টিউটোরিয়াল' : 'Help & Tutorial';
  String get learnHowToUse => localeName == 'bn' ? 'কেন এইড কীভাবে ব্যবহার করবেন তা শিখুন' : 'Learn how to use Cane AID';
  String get about => localeName == 'bn' ? 'সম্পর্কে' : 'About';
  String get aboutCaneAid => localeName == 'bn' ? 'কেন এইড সম্পর্কে' : 'About Cane AID';
  String get appVersionAndInfo => localeName == 'bn' ? 'অ্যাপ সংস্করণ এবং তথ্য' : 'App version and information';
  String get assistiveTechnology => localeName == 'bn' ? 'দৃষ্টি প্রতিবন্ধী ব্যবহারকারীদের জন্য সহায়ক প্রযুক্তি' : 'Assistive technology for visually impaired users';
  String get features => localeName == 'bn' ? 'বৈশিষ্ট্য:' : 'Features:';
  String get colorDetectionViaEsp32 => localeName == 'bn' ? '• ESP32 এর মাধ্যমে রঙ সনাক্তকরণ' : '• Color detection via ESP32';
  String get distanceDetectionFeature => localeName == 'bn' ? '• দূরত্ব সনাক্তকরণ' : '• Distance detection';
  String get gpsLocationSharing => localeName == 'bn' ? '• GPS অবস্থান ভাগাভাগি' : '• GPS location sharing';
  String get voiceFeedbackBengaliEnglish => localeName == 'bn' ? '• ইংরেজি/বাংলায় ভয়েস ফিডব্যাক' : '• Voice feedback in English/Bangla';
  String get close => localeName == 'bn' ? 'বন্ধ' : 'Close';
  
  // Distance and Location features
  String get distanceDetectionScreen => localeName == 'bn' ? 'দূরত্ব সনাক্তকরণ স্ক্রিন' : 'Distance Detection Screen';
  String get realTimeDistanceMeasurement => localeName == 'bn' ? 'রিয়েল-টাইম দূরত্ব পরিমাপ এবং বিপদ সতর্কতা' : 'Real-time distance measurement and hazard alerts';
  String get ready => localeName == 'bn' ? 'প্রস্তুত' : 'Ready';
  String get detecting => localeName == 'bn' ? 'সনাক্ত করা হচ্ছে...' : 'Detecting...';
  String get veryClose => localeName == 'bn' ? 'খুব কাছে!' : 'Very Close!';
  String get closeDistance => localeName == 'bn' ? 'কাছাকাছি' : 'Close';
  String get mediumDistance => localeName == 'bn' ? 'মাঝারি' : 'Medium';
  String get safeDistance => localeName == 'bn' ? 'নিরাপদ দূরত্ব' : 'Safe Distance';
  String get instructions => localeName == 'bn' ? 'নির্দেশাবলী:' : 'Instructions:';
  String get location => localeName == 'bn' ? 'অবস্থান' : 'Location';
  String get locationScreen => localeName == 'bn' ? 'অবস্থান স্ক্রিন' : 'Location Screen';
  String get shareLocationWithCaretaker => localeName == 'bn' ? 'পরিচর্যাকারীর সাথে আপনার অবস্থান ভাগ করুন' : 'Share your location with caretaker';
  
  String get bluetoothDisabled => localeName == 'bn' ? 'ব্লুটুথ নিষ্ক্রিয়' : 'Bluetooth Disabled';
  String get bluetoothDisabledMessage => localeName == 'bn' ? 'আপনার ESP32 ডিভাইসের সাথে সংযোগ করতে দয়া করে ব্লুটুথ সক্রিয় করুন।' : 'Please enable Bluetooth to connect to your ESP32 device.';
  String get cancel => localeName == 'bn' ? 'বাতিল' : 'Cancel';
  String get enable => localeName == 'bn' ? 'সক্রিয় করুন' : 'Enable';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale.languageCode));
  }

  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
