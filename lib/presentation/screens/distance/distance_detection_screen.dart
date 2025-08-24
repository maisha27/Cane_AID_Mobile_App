import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/config/websocket_config.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/common/accessible_card.dart';
import '../../providers/tts_provider.dart';
import '../../providers/websocket_provider.dart';
import '../../../core/models/esp32_data.dart';

/// Distance Detection screen for real-time obstacle detection
/// Uses ultrasonic sensor data from ESP32 to measure distances and provide voice alerts
class DistanceDetectionScreen extends StatefulWidget {
  const DistanceDetectionScreen({super.key});

  @override
  State<DistanceDetectionScreen> createState() => _DistanceDetectionScreenState();
}

class _DistanceDetectionScreenState extends State<DistanceDetectionScreen> {
  bool _isDetecting = false;
  double _currentDistance = 0.0;
  String _distanceStatus = 'Ready';
  String _lastAnnouncedZone = '';

  @override
  void initState() {
    super.initState();
    _listenToDistanceData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceScreenEntry();
    });
  }

  void _listenToDistanceData() {
    // For Phase 2, focus on WebSocket provider only
    // TODO: Update BluetoothProvider to use unified ESP32Data model in Phase 3
    final websocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
    
    // Listen to WebSocket distance data stream
    websocketProvider.dataStream.listen((esp32Data) {
      if (esp32Data.distanceData != null && _isDetecting) {
        _processDistanceData(esp32Data.distanceData!);
      }
    });
  }

  void _processDistanceData(DistanceData distanceData) async {
    if (!mounted) return;
    
    final oldDistance = _currentDistance;
    setState(() {
      _currentDistance = distanceData.distance;
      _distanceStatus = _isDetecting ? 'Detecting' : 'Ready';
    });
    
    // Announce distance zone changes
    _announceDistanceChange(oldDistance, _currentDistance);
  }

  void _announceScreenEntry() async {
    if (!mounted) return;
    
    try {
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        await ttsProvider.announceScreenEntry(l10n.distanceDetectionScreen);
        
        await Future.delayed(const Duration(milliseconds: 1000));
        await ttsProvider.speak(l10n.realTimeDistanceMeasurement);
      }
    } catch (e) {
      debugPrint('TTS announcement error: $e');
    }
    
    HapticFeedback.lightImpact();
  }

  void _toggleDetection() async {
    final websocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (_isDetecting) {
      // Stop detection
      setState(() {
        _isDetecting = false;
        _distanceStatus = l10n.ready;
      });
      await ttsProvider.speak(l10n.stop);
      HapticFeedback.lightImpact();
      return;
    }

    // Smart connection: Try WebSocket first
    bool connected = false;
    
    // Try WebSocket connection (automatic)
    if (!websocketProvider.isConnected) {
      await ttsProvider.speak('Connecting to ESP32 server...');
      connected = await _tryWebSocketConnection(websocketProvider);
    } else {
      connected = true;
    }

    // If WebSocket fails, use simulation mode
    if (!connected) {
      await ttsProvider.speak('No ESP32 server available. Using simulation mode');
      _startSimulationMode();
      return;
    }

    // Start detection with WebSocket
    setState(() {
      _isDetecting = true;
      _distanceStatus = l10n.detecting;
    });
    await ttsProvider.speak('Distance detection started');
    HapticFeedback.heavyImpact();
  }

  /// Try to connect via WebSocket automatically
  Future<bool> _tryWebSocketConnection(WebSocketProvider websocketProvider) async {
    try {
      // Try default WebSocket URL from configuration
      final success = await websocketProvider.connectToServer(
        customUrl: WebSocketConfig.defaultServerUrl
      );
      
      // Wait a moment to check connection
      await Future.delayed(Duration(seconds: WebSocketConfig.connectionTimeoutSeconds));
      
      return success && websocketProvider.isConnected;
    } catch (e) {
      debugPrint('Auto WebSocket connection failed: $e');
      return false;
    }
  }

  /// Start simulation mode when no ESP32 connection available
  void _startSimulationMode() async {
    setState(() {
      _isDetecting = true;
      _distanceStatus = AppLocalizations.of(context)!.detecting;
    });
    
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    await ttsProvider.speak('Simulation mode activated');
    
    _startDistanceSimulation();
  }

  void _startDistanceSimulation() {
    // Simulate distance readings for demo purposes
    if (_isDetecting && mounted) {
      final oldDistance = _currentDistance;
      setState(() {
        _currentDistance = 50.0 + (DateTime.now().millisecondsSinceEpoch % 100);
      });
      
      // Announce distance zone changes
      _announceDistanceChange(oldDistance, _currentDistance);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isDetecting) {
          _startDistanceSimulation();
        }
      });
    }
  }

  void _announceDistanceChange(double oldDistance, double newDistance) async {
    final l10n = AppLocalizations.of(context)!;
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    
    String newZone = _getDistanceZone(newDistance);
    String oldZone = _getDistanceZone(oldDistance);
    
    // Only announce if zone changed and not too frequent
    if (newZone != oldZone && newZone != _lastAnnouncedZone) {
      _lastAnnouncedZone = newZone;
      
      String announcement = '';
      if (newDistance < 30) {
        announcement = l10n.veryClose;
        HapticFeedback.heavyImpact();
      } else if (newDistance < 60) {
        announcement = l10n.closeDistance;
        HapticFeedback.mediumImpact();
      } else if (newDistance < 100) {
        announcement = l10n.mediumDistance;
        HapticFeedback.lightImpact();
      } else {
        announcement = l10n.safeDistance;
      }
      
      await ttsProvider.speak(announcement);
    }
  }

  String _getDistanceZone(double distance) {
    if (distance < 30) return 'very_close';
    if (distance < 60) return 'close';
    if (distance < 100) return 'medium';
    return 'safe';
  }

  Color _getDistanceColor() {
    if (_currentDistance < 30) return AppColors.error;
    if (_currentDistance < 60) return AppColors.warning;
    if (_currentDistance < 100) return AppColors.accent;
    return AppColors.success;
  }

  String _getDistanceStatusText(AppLocalizations l10n) {
    if (!_isDetecting) return l10n.ready;
    if (_currentDistance < 30) return l10n.veryClose;
    if (_currentDistance < 60) return l10n.closeDistance;
    if (_currentDistance < 100) return l10n.mediumDistance;
    return l10n.safeDistance;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.distanceDetection,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.textLight,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          tooltip: 'Go back',
        ),
      ),
      body: SafeArea(
        child: Semantics(
          label: '${l10n.distanceDetectionScreen}. ${l10n.realTimeDistanceMeasurement}',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              children: [
                // Distance Display Card
                AccessibleCard(
                  child: Column(
                    children: [
                      Icon(
                        _isDetecting ? Icons.radar : Icons.radar_outlined,
                        size: 80,
                        color: _isDetecting ? _getDistanceColor() : AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppDimensions.marginMedium),
                      Text(
                        _getDistanceStatusText(l10n),
                        style: AppTextStyles.heading3.copyWith(
                          color: _isDetecting ? _getDistanceColor() : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginSmall),
                      Text(
                        '${_currentDistance.toStringAsFixed(1)} cm',
                        style: AppTextStyles.heading1.copyWith(
                          color: _getDistanceColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginSmall),
                      Text(
                        _distanceStatus,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppDimensions.marginLarge),
                
                // Control Button
                Center(
                  child: ElevatedButton(
                    onPressed: _toggleDetection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isDetecting ? AppColors.error : AppColors.primary,
                      foregroundColor: AppColors.textLight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLarge * 2,
                        vertical: AppDimensions.paddingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                    ),
                    child: Text(
                      _isDetecting ? l10n.stop : l10n.start,
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppDimensions.marginLarge),
                
                // Instructions Card
                AccessibleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.instructions,
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginSmall),
                      Text(
                        '• Point your cane forward\n'
                        '• Press Start to begin detection\n'
                        '• Listen for voice distance alerts\n'
                        '• Feel haptic feedback for obstacles\n'
                        '• Red: Very close (<30cm)\n'
                        '• Orange: Close (30-60cm)\n'
                        '• Yellow: Medium (60-100cm)\n'
                        '• Green: Safe (>100cm)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
