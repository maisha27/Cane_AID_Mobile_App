import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cane AID'**
  String get appTitle;

  /// No description provided for @homeScreen.
  ///
  /// In en, this message translates to:
  /// **'Home Screen'**
  String get homeScreen;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Cane AID'**
  String get welcomeMessage;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your assistive companion for daily navigation'**
  String get welcomeSubtitle;

  /// No description provided for @colorDetection.
  ///
  /// In en, this message translates to:
  /// **'Color Detection'**
  String get colorDetection;

  /// No description provided for @colorDetectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Identify colors around you'**
  String get colorDetectionSubtitle;

  /// No description provided for @colorDetectionScreen.
  ///
  /// In en, this message translates to:
  /// **'Color Detection Screen'**
  String get colorDetectionScreen;

  /// No description provided for @detectedColor.
  ///
  /// In en, this message translates to:
  /// **'Detected Color'**
  String get detectedColor;

  /// No description provided for @startDetection.
  ///
  /// In en, this message translates to:
  /// **'Start Detection'**
  String get startDetection;

  /// No description provided for @stopDetection.
  ///
  /// In en, this message translates to:
  /// **'Stop Detection'**
  String get stopDetection;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @colorHistory.
  ///
  /// In en, this message translates to:
  /// **'Color History'**
  String get colorHistory;

  /// No description provided for @noColorDetected.
  ///
  /// In en, this message translates to:
  /// **'No color detected'**
  String get noColorDetected;

  /// No description provided for @tapStartDetection.
  ///
  /// In en, this message translates to:
  /// **'Tap start detection to identify colors around you'**
  String get tapStartDetection;

  /// No description provided for @distanceDetection.
  ///
  /// In en, this message translates to:
  /// **'Distance Detection'**
  String get distanceDetection;

  /// No description provided for @distanceDetectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detect nearby objects'**
  String get distanceDetectionSubtitle;

  /// No description provided for @locationServices.
  ///
  /// In en, this message translates to:
  /// **'Location Services'**
  String get locationServices;

  /// No description provided for @locationServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your location'**
  String get locationServicesSubtitle;

  /// No description provided for @deviceConnection.
  ///
  /// In en, this message translates to:
  /// **'Device Connection'**
  String get deviceConnection;

  /// No description provided for @deviceConnectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to ESP32'**
  String get deviceConnectionSubtitle;

  /// No description provided for @bluetoothConnection.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Connection'**
  String get bluetoothConnection;

  /// No description provided for @bluetoothConnectionScreen.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Connection Screen'**
  String get bluetoothConnectionScreen;

  /// No description provided for @connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get connectionStatus;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @scanningForDevices.
  ///
  /// In en, this message translates to:
  /// **'Scanning for ESP32 devices'**
  String get scanningForDevices;

  /// No description provided for @stopScanning.
  ///
  /// In en, this message translates to:
  /// **'Stop scanning for devices'**
  String get stopScanning;

  /// No description provided for @discoveredDevices.
  ///
  /// In en, this message translates to:
  /// **'Discovered Devices'**
  String get discoveredDevices;

  /// No description provided for @pairedDevices.
  ///
  /// In en, this message translates to:
  /// **'Paired Devices'**
  String get pairedDevices;

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No ESP32 devices found'**
  String get noDevicesFound;

  /// No description provided for @noDevicesFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make sure your device is powered on and in pairing mode'**
  String get noDevicesFoundSubtitle;

  /// No description provided for @noPairedDevices.
  ///
  /// In en, this message translates to:
  /// **'No paired ESP32 devices'**
  String get noPairedDevices;

  /// No description provided for @connectToDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect to your ESP32 Cane AID device'**
  String get connectToDevice;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @tutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorial;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bangla;

  /// No description provided for @bluetoothDisabled.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Disabled'**
  String get bluetoothDisabled;

  /// No description provided for @bluetoothDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable Bluetooth to connect to your ESP32 device.'**
  String get bluetoothDisabledMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
