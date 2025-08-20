import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/services/color_api_service.dart';
import '../../widgets/common/accessible_card.dart';
import '../../widgets/common/accessible_button.dart';
import '../../providers/tts_provider.dart';
import '../../providers/bluetooth_provider.dart';
import '../../../core/services/bluetooth_service.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Color detection screen for identifying colors using ESP32 color sensor
/// Provides real-time color detection with voice feedback
class ColorDetectionScreen extends StatefulWidget {
  const ColorDetectionScreen({super.key});

  @override
  State<ColorDetectionScreen> createState() => _ColorDetectionScreenState();
}

class _ColorDetectionScreenState extends State<ColorDetectionScreen> {
  String _currentColorName = 'No color detected';
  Color _currentColor = Colors.grey;
  ColorData? _latestColorData;
  bool _isDetecting = false;
  final List<DetectedColor> _colorHistory = [];

  @override
  void initState() {
    super.initState();
    _announceScreenEntry();
    _listenToColorData();
  }

  void _announceScreenEntry() async {
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        final l10n = AppLocalizations.of(context)!;
        
        await ttsProvider.announceScreenEntry(l10n.colorDetectionScreen);
        
        await Future.delayed(const Duration(milliseconds: 1000));
        await ttsProvider.speak(l10n.tapStartDetection);
      } catch (e) {
        debugPrint('TTS announcement error: $e');
      }
      
      HapticFeedback.lightImpact();
    });
  }

  void _listenToColorData() {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    
    // Listen to color data stream
    bluetoothProvider.dataStream.listen((esp32Data) {
      if (esp32Data.colorData != null && _isDetecting) {
        _processColorData(esp32Data.colorData!);
      }
    });
  }

  void _processColorData(ColorData colorData) async {
    if (!mounted) return;
    
    setState(() {
      _latestColorData = colorData;
      _currentColor = Color.fromRGBO(
        colorData.red.toInt(),
        colorData.green.toInt(),
        colorData.blue.toInt(),
        1.0,
      );
    });

    // Get color name from RGB values
    final colorName = await _getColorName(colorData.red.toDouble(), colorData.green.toDouble(), colorData.blue.toDouble());
    
    if (!mounted) return;
    
    setState(() {
      _currentColorName = colorName;
    });

    // Add to history
    final detectedColor = DetectedColor(
      name: colorName,
      color: _currentColor,
      rgbValues: 'RGB(${colorData.red.toInt()}, ${colorData.green.toInt()}, ${colorData.blue.toInt()})',
      timestamp: DateTime.now(),
    );

    if (!mounted) return;

    setState(() {
      _colorHistory.insert(0, detectedColor);
      if (_colorHistory.length > 10) {
        _colorHistory.removeLast();
      }
    });

    // Announce color
    if (!mounted) return;
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    await ttsProvider.speak('Detected color: $colorName');
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  Future<String> _getColorName(double red, double green, double blue) async {
    try {
      // Use enhanced color API service
      final colorResult = await ColorApiService.getColorName(
        red.toInt(),
        green.toInt(),
        blue.toInt(),
      );
      return colorResult.name;
    } catch (e) {
      debugPrint('Error getting color name: $e');
      return 'Unknown color';
    }
  }

  void _toggleDetection() async {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);

    if (!bluetoothProvider.isConnected) {
      await ttsProvider.speak('Please connect to ESP32 device first');
      return;
    }

    setState(() {
      _isDetecting = !_isDetecting;
    });

    if (_isDetecting) {
      await ttsProvider.speak('Color detection started');
    } else {
      await ttsProvider.speak('Color detection stopped');
    }

    HapticFeedback.selectionClick();
  }

  void _clearHistory() async {
    setState(() {
      _colorHistory.clear();
    });

    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    await ttsProvider.speak('Color history cleared');
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.colorDetection,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.textLight,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textLight,
          ),
          tooltip: 'Go back',
        ),
      ),
      body: SafeArea(
        child: Consumer2<BluetoothProvider, TTSProvider>(
          builder: (context, bluetoothProvider, ttsProvider, child) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connection Status
                  _buildConnectionStatus(bluetoothProvider),
                  
                  const SizedBox(height: AppDimensions.marginLarge),
                  
                  // Current Color Display
                  _buildCurrentColorDisplay(),
                  
                  const SizedBox(height: AppDimensions.marginLarge),
                  
                  // Control Buttons
                  _buildControlButtons(bluetoothProvider),
                  
                  const SizedBox(height: AppDimensions.marginLarge),
                  
                  // Color History
                  SizedBox(
                    height: 300, // Fixed height for history section
                    child: _buildColorHistory(),
                  ),
                  
                  const SizedBox(height: AppDimensions.marginLarge),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(BluetoothProvider bluetoothProvider) {
    return AccessibleCard(
      semanticLabel: bluetoothProvider.isConnected 
          ? 'ESP32 device connected and ready' 
          : 'ESP32 device not connected',
      child: Row(
        children: [
          Icon(
            bluetoothProvider.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: bluetoothProvider.isConnected ? AppColors.success : AppColors.error,
            size: AppDimensions.iconMedium,
          ),
          const SizedBox(width: AppDimensions.marginMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bluetoothProvider.isConnected ? 'ESP32 Connected' : 'ESP32 Disconnected',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: bluetoothProvider.isConnected ? AppColors.success : AppColors.error,
                  ),
                ),
                Text(
                  bluetoothProvider.isConnected 
                      ? 'Color sensor ready for detection'
                      : 'Connect device to start detection',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentColorDisplay() {
    final l10n = AppLocalizations.of(context)!;
    
    return AccessibleCard(
      semanticLabel: 'Current detected color: $_currentColorName',
      child: Column(
        children: [
          Text(
            l10n.detectedColor,
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          
          // Color Circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _currentColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.colorCardBorder,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppDimensions.marginMedium),
          
          Text(
            _currentColorName,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (_latestColorData != null) ...[
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              'RGB(${_latestColorData!.red.toInt()}, ${_latestColorData!.green.toInt()}, ${_latestColorData!.blue.toInt()})',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButtons(BluetoothProvider bluetoothProvider) {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        Expanded(
          child: AccessibleButton(
            onPressed: bluetoothProvider.isConnected ? _toggleDetection : null,
            semanticLabel: _isDetecting ? l10n.stopDetection : l10n.startDetection,
            backgroundColor: _isDetecting ? AppColors.error : AppColors.success,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_isDetecting ? Icons.stop : Icons.play_arrow),
                const SizedBox(width: AppDimensions.marginSmall),
                Flexible(
                  child: Text(
                    _isDetecting ? l10n.stop : l10n.startDetection,
                    style: AppTextStyles.buttonMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.marginMedium),
        Expanded(
          child: AccessibleButton(
            onPressed: _colorHistory.isNotEmpty ? _clearHistory : null,
            semanticLabel: l10n.clearHistory,
            backgroundColor: AppColors.warning,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.clear),
                const SizedBox(width: AppDimensions.marginSmall),
                Flexible(
                  child: Text(
                    l10n.clearHistory,
                    style: AppTextStyles.buttonMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorHistory() {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.colorHistory,
          style: AppTextStyles.heading4,
        ),
        const SizedBox(height: AppDimensions.marginMedium),
        
        Expanded(
          child: _colorHistory.isEmpty
              ? _buildEmptyHistory()
              : ListView.builder(
                  itemCount: _colorHistory.length,
                  itemBuilder: (context, index) {
                    final color = _colorHistory[index];
                    return _buildColorHistoryItem(color, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: AppDimensions.iconXLarge,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          Text(
            'No colors detected yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            'Start detection to see color history',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorHistoryItem(DetectedColor detectedColor, int index) {
    return AccessibleCard(
      semanticLabel: 'Detected ${detectedColor.name} at ${_formatTime(detectedColor.timestamp)}',
      margin: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      onTap: () async {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        await ttsProvider.speak('${detectedColor.name}. ${detectedColor.rgbValues}');
      },
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: detectedColor.color,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(
                color: AppColors.colorCardBorder,
                width: 1,
              ),
            ),
          ),
          
          const SizedBox(width: AppDimensions.marginMedium),
          
          // Color details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detectedColor.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.marginXSmall),
                Text(
                  detectedColor.rgbValues,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Timestamp
          Text(
            _formatTime(detectedColor.timestamp),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Model class for detected color with history
class DetectedColor {
  final String name;
  final Color color;
  final String rgbValues;
  final DateTime timestamp;

  DetectedColor({
    required this.name,
    required this.color,
    required this.rgbValues,
    required this.timestamp,
  });
}
