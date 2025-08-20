import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/app_constants.dart';

/// Text-to-Speech service for providing voice feedback
/// Supports both English and Bangla with configurable settings
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _currentLanguage = AppConstants.defaultLanguage;
  double _speechRate = AppConstants.defaultTTSSpeed;
  double _pitch = AppConstants.defaultTTSPitch;
  double _volume = AppConstants.defaultTTSVolume;

  // Available voices cache
  List<dynamic> _availableVoices = [];
  Map<String, dynamic>? _selectedVoice;

  /// Initialize TTS service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _flutterTts = FlutterTts();
      
      // Set up TTS callbacks
      await _setupCallbacks();
      
      // Load available voices
      await _loadAvailableVoices();
      
      // Set default configuration
      await _applyDefaultSettings();
      
      _isInitialized = true;
      debugPrint('TTS Service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('TTS Service initialization failed: $e');
      return false;
    }
  }

  /// Set up TTS event callbacks
  Future<void> _setupCallbacks() async {
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      debugPrint('TTS: Speech started');
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      debugPrint('TTS: Speech completed');
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      debugPrint('TTS Error: $msg');
    });

    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
      debugPrint('TTS: Speech cancelled');
    });

    _flutterTts.setPauseHandler(() {
      debugPrint('TTS: Speech paused');
    });

    _flutterTts.setContinueHandler(() {
      debugPrint('TTS: Speech resumed');
    });
  }

  /// Load available voices from the system
  Future<void> _loadAvailableVoices() async {
    try {
      _availableVoices = await _flutterTts.getVoices ?? [];
      debugPrint('TTS: Found ${_availableVoices.length} voices');
      
      // Find best voice for current language
      await _selectBestVoice(_currentLanguage);
    } catch (e) {
      debugPrint('TTS: Error loading voices: $e');
    }
  }

  /// Select the best available voice for the given language
  Future<void> _selectBestVoice(String languageCode) async {
    try {
      // Find voices matching the language
      List<dynamic> matchingVoices = _availableVoices.where((voice) {
        String voiceLocale = voice['locale'] ?? '';
        return voiceLocale.startsWith(languageCode);
      }).toList();

      if (matchingVoices.isNotEmpty) {
        _selectedVoice = matchingVoices.first;
        await _flutterTts.setVoice({
          'name': _selectedVoice!['name'],
          'locale': _selectedVoice!['locale'],
        });
        debugPrint('TTS: Selected voice: ${_selectedVoice!['name']}');
      } else {
        debugPrint('TTS: No voice found for language: $languageCode');
      }
    } catch (e) {
      debugPrint('TTS: Error selecting voice: $e');
    }
  }

  /// Apply default TTS settings
  Future<void> _applyDefaultSettings() async {
    try {
      await _flutterTts.setLanguage(_currentLanguage);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setVolume(_volume);
      
      // Platform-specific settings
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _flutterTts.setQueueMode(1); // Queue mode
      }
    } catch (e) {
      debugPrint('TTS: Error applying settings: $e');
    }
  }

  /// Speak the given text
  Future<void> speak(String text, {
    String? languageCode,
    bool interrupt = false,
    double? customRate,
    double? customPitch,
  }) async {
    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) return;
    }

    if (text.trim().isEmpty) return;

    try {
      // Stop current speech if interrupting
      if (interrupt && _isSpeaking) {
        await stop();
      }

      // Apply custom settings if provided
      if (languageCode != null && languageCode != _currentLanguage) {
        await setLanguage(languageCode);
      }
      
      if (customRate != null) {
        await _flutterTts.setSpeechRate(customRate);
      }
      
      if (customPitch != null) {
        await _flutterTts.setPitch(customPitch);
      }

      debugPrint('TTS: Speaking: $text');
      await _flutterTts.speak(text);
      
      // Restore default settings if custom ones were used
      if (customRate != null) {
        await _flutterTts.setSpeechRate(_speechRate);
      }
      
      if (customPitch != null) {
        await _flutterTts.setPitch(_pitch);
      }
      
    } catch (e) {
      debugPrint('TTS: Error speaking: $e');
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    if (!_isInitialized) return;
    
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('TTS: Error stopping: $e');
    }
  }

  /// Pause current speech
  Future<void> pause() async {
    if (!_isInitialized) return;
    
    try {
      await _flutterTts.pause();
    } catch (e) {
      debugPrint('TTS: Error pausing: $e');
    }
  }

  /// Set TTS language
  Future<void> setLanguage(String languageCode) async {
    if (!_isInitialized) return;
    
    try {
      // Check if the language is available
      List<dynamic> languages = await _flutterTts.getLanguages;
      debugPrint('TTS: Available languages: $languages');
      
      // Bengali language variants to try in order
      List<String> bengaliVariants = ['bn-IN', 'bn-BD', 'bn'];
      List<String> englishVariants = ['en-US', 'en-GB', 'en'];
      
      bool languageSet = false;
      
      if (languageCode.startsWith('bn')) {
        // Try Bengali variants
        for (String variant in bengaliVariants) {
          if (languages.contains(variant)) {
            await _flutterTts.setLanguage(variant);
            _currentLanguage = variant;
            await _selectBestVoice(variant);
            debugPrint('TTS: Bengali language set to: $variant');
            languageSet = true;
            break;
          }
        }
      } else if (languageCode.startsWith('en')) {
        // Try English variants
        for (String variant in englishVariants) {
          if (languages.contains(variant)) {
            await _flutterTts.setLanguage(variant);
            _currentLanguage = variant;
            await _selectBestVoice(variant);
            debugPrint('TTS: English language set to: $variant');
            languageSet = true;
            break;
          }
        }
      }
      
      if (!languageSet) {
        debugPrint('TTS: No suitable language found for $languageCode, keeping current: $_currentLanguage');
      }
    } catch (e) {
      debugPrint('TTS: Error setting language: $e');
    }
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) return;
    
    try {
      _speechRate = rate.clamp(0.0, 1.0);
      await _flutterTts.setSpeechRate(_speechRate);
      debugPrint('TTS: Speech rate set to: $_speechRate');
    } catch (e) {
      debugPrint('TTS: Error setting speech rate: $e');
    }
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) return;
    
    try {
      _pitch = pitch.clamp(0.5, 2.0);
      await _flutterTts.setPitch(_pitch);
      debugPrint('TTS: Pitch set to: $_pitch');
    } catch (e) {
      debugPrint('TTS: Error setting pitch: $e');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;
    
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _flutterTts.setVolume(_volume);
      debugPrint('TTS: Volume set to: $_volume');
    } catch (e) {
      debugPrint('TTS: Error setting volume: $e');
    }
  }

  /// Check if TTS is currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Get current language
  String get currentLanguage => _currentLanguage;

  /// Get current speech rate
  double get speechRate => _speechRate;

  /// Get current pitch
  double get pitch => _pitch;

  /// Get current volume
  double get volume => _volume;

  /// Get available voices
  List<dynamic> get availableVoices => _availableVoices;

  /// Dispose of TTS resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await stop();
      _isInitialized = false;
    }
  }

  /// Quick speak methods for common UI interactions
  Future<void> speakButtonPress(String buttonText) async {
    await speak('$buttonText button activated', interrupt: false);
  }

  Future<void> speakScreenEntry(String screenName) async {
    await speak('Entered $screenName screen', interrupt: true);
  }

  Future<void> speakNavigationAction(String action) async {
    await speak(action, interrupt: false);
  }

  Future<void> speakError(String error) async {
    await speak('Error: $error', interrupt: true, customPitch: 0.8);
  }

  Future<void> speakSuccess(String message) async {
    await speak('Success: $message', interrupt: false, customPitch: 1.2);
  }

  /// English-only speak method
  Future<void> speakInEnglish(String text) async {
    await speak(text, languageCode: AppConstants.englishLanguageCode);
  }
}
