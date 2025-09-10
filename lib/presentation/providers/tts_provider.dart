import 'package:flutter/material.dart';
import '../../core/services/tts_service.dart';
import '../../core/constants/app_constants.dart';

/// Provider for managing TTS state and settings
/// Handles voice feedback configuration and user preferences
class TTSProvider extends ChangeNotifier {
  final TTSService _ttsService = TTSService();
  
  bool _isInitialized = false;
  bool _isEnabled = true;
  bool _isSpeaking = false;
  String _currentLanguage = AppConstants.defaultLanguage;
  double _speechRate = AppConstants.defaultTTSSpeed;
  double _pitch = AppConstants.defaultTTSPitch;
  double _volume = AppConstants.defaultTTSVolume;
  
  // UI voice feedback settings
  bool _announceButtonPresses = true;
  bool _announceScreenChanges = true;
  bool _announceErrors = true;
  bool _announceStatusUpdates = true;

  /// Getters
  bool get isInitialized => _isInitialized;
  bool get isEnabled => _isEnabled;
  bool get isSpeaking => _isSpeaking;
  String get currentLanguage => _currentLanguage;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;
  bool get announceButtonPresses => _announceButtonPresses;
  bool get announceScreenChanges => _announceScreenChanges;
  bool get announceErrors => _announceErrors;
  bool get announceStatusUpdates => _announceStatusUpdates;

  /// Initialize TTS service
  Future<void> initialize() async {
    try {
      _isInitialized = await _ttsService.initialize();
      
      if (_isInitialized) {
        // Load saved settings
        await _loadSettings();
        
        // Apply settings to TTS service
        await _applySettings();
        
        debugPrint('TTS Provider initialized successfully');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('TTS Provider initialization error: $e');
      _isInitialized = false;
      notifyListeners();
    }
  }

  /// Load settings from local storage
  Future<void> _loadSettings() async {
    // TODO: Implement settings loading from SharedPreferences/Hive
    // For now, use defaults
    debugPrint('TTS Provider: Loading settings (using defaults for now)');
  }

  /// Apply current settings to TTS service
  Future<void> _applySettings() async {
    if (!_isInitialized) return;

    await _ttsService.setLanguage(_currentLanguage);
    await _ttsService.setSpeechRate(_speechRate);
    await _ttsService.setPitch(_pitch);
    await _ttsService.setVolume(_volume);
  }

  /// Save settings to local storage
  Future<void> _saveSettings() async {
    // TODO: Implement settings saving to SharedPreferences/Hive
    debugPrint('TTS Provider: Saving settings');
  }

  /// Enable/disable TTS
  Future<void> setEnabled(bool enabled) async {
    if (_isEnabled == enabled) return;
    
    _isEnabled = enabled;
    
    if (!enabled && _isSpeaking) {
      await _ttsService.stop();
    }
    
    await _saveSettings();
    notifyListeners();
    
    if (enabled) {
      await speak('Voice feedback enabled');
    }
  }

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;
    
    _currentLanguage = languageCode;
    
    if (_isInitialized) {
      await _ttsService.setLanguage(languageCode);
    }
    
    await _saveSettings();
    notifyListeners();
    
    // Announce language change in English
    await speak('Language changed to English');
  }

  /// Set speech rate
  Future<void> setSpeechRate(double rate) async {
    double clampedRate = rate.clamp(0.1, 1.0);
    if (_speechRate == clampedRate) return;
    
    _speechRate = clampedRate;
    
    if (_isInitialized) {
      await _ttsService.setSpeechRate(clampedRate);
    }
    
    await _saveSettings();
    notifyListeners();
  }

  /// Set pitch
  Future<void> setPitch(double pitch) async {
    double clampedPitch = pitch.clamp(0.5, 2.0);
    if (_pitch == clampedPitch) return;
    
    _pitch = clampedPitch;
    
    if (_isInitialized) {
      await _ttsService.setPitch(clampedPitch);
    }
    
    await _saveSettings();
    notifyListeners();
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    double clampedVolume = volume.clamp(0.0, 1.0);
    if (_volume == clampedVolume) return;
    
    _volume = clampedVolume;
    
    if (_isInitialized) {
      await _ttsService.setVolume(clampedVolume);
    }
    
    await _saveSettings();
    notifyListeners();
  }

  /// Set UI announcement preferences
  Future<void> setAnnounceButtonPresses(bool announce) async {
    _announceButtonPresses = announce;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setAnnounceScreenChanges(bool announce) async {
    _announceScreenChanges = announce;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setAnnounceErrors(bool announce) async {
    _announceErrors = announce;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setAnnounceStatusUpdates(bool announce) async {
    _announceStatusUpdates = announce;
    await _saveSettings();
    notifyListeners();
  }

  /// Core speak method
  Future<void> speak(String text, {
    bool interrupt = false,
    String? languageCode,
    double? customRate,
    double? customPitch,
  }) async {
    if (!_isEnabled || !_isInitialized || text.trim().isEmpty) return;

    _isSpeaking = true;
    notifyListeners();

    try {
      await _ttsService.speak(
        text,
        languageCode: languageCode,
        interrupt: interrupt,
        customRate: customRate,
        customPitch: customPitch,
      );
    } finally {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    if (_isInitialized) {
      await _ttsService.stop();
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// UI-specific announcement methods
  Future<void> announceButtonPress(String buttonText) async {
    if (_announceButtonPresses) {
      await speak('$buttonText activated');
    }
  }

  Future<void> announceScreenEntry(String screenName) async {
    if (_announceScreenChanges) {
      await speak('Entered $screenName', interrupt: true);
    }
  }

  Future<void> announceNavigation(String action) async {
    if (_announceScreenChanges) {
      await speak(action);
    }
  }

  Future<void> announceError(String error) async {
    if (_announceErrors) {
      await speak('Error: $error', interrupt: true, customPitch: 0.8);
    }
  }

  Future<void> announceSuccess(String message) async {
    if (_announceStatusUpdates) {
      await speak(message, customPitch: 1.2);
    }
  }

  Future<void> announceWarning(String warning) async {
    if (_announceStatusUpdates) {
      await speak('Warning: $warning', interrupt: true);
    }
  }

  /// Feature-specific announcements
  Future<void> announceColorDetection(String colorName) async {
    String message = 'Color detected: $colorName';
    await speak(message, interrupt: true);
  }

  Future<void> announceDistanceWarning(double distance) async {
    String message = 'Warning! Object at ${distance.toInt()} centimeters';
    await speak(message, interrupt: true, customPitch: 0.7);
  }

  Future<void> announceLocationUpdate(String location) async {
    String message = 'Current location: $location';
    await speak(message);
  }

  /// Test TTS with current settings
  Future<void> testSpeech() async {
    String testMessage = 'This is a test message';
    await speak(testMessage, interrupt: true);
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}
