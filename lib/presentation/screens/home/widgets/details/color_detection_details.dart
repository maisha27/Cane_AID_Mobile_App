import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/theme/dimensions.dart';
import '../../../../widgets/common/accessible_card.dart';
import '../../../../providers/websocket_provider.dart';
import '../../../../providers/tts_provider.dart';

/// Color Detection Details Widget
/// Shows expanded color detection interface with real-time RGB values and color preview
class ColorDetectionDetails extends StatefulWidget {
  final VoidCallback? onCollapse;
  
  const ColorDetectionDetails({
    super.key,
    this.onCollapse,
  });

  @override
  State<ColorDetectionDetails> createState() => _ColorDetectionDetailsState();
}

class _ColorDetectionDetailsState extends State<ColorDetectionDetails>
    with SingleTickerProviderStateMixin {
  bool _isDetecting = false;
  String _lastDetectedColor = 'No color detected';
  String _lastAnnouncedColor = '';
  late AnimationController _colorAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceExpansion();
    });
  }

  void _setupAnimations() {
    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _colorAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimationController.forward();
  }

  void _announceExpansion() async {
    try {
      final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
      await ttsProvider.speak('Color Detection section expanded');
      await Future.delayed(const Duration(milliseconds: 500));
      await ttsProvider.speak('Tap start to begin color detection');
    } catch (e) {
      debugPrint('TTS announcement error: $e');
    }
    HapticFeedback.lightImpact();
  }

  void _toggleDetection() async {
    final websocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);

    setState(() {
      _isDetecting = !_isDetecting;
    });

    if (_isDetecting) {
      await ttsProvider.speak('Color detection started');
      HapticFeedback.heavyImpact();
      
      // Try to connect to WebSocket if not connected
      if (!websocketProvider.isConnected) {
        await ttsProvider.speak('Connecting to device...');
        await websocketProvider.connectToServer();
      }
    } else {
      await ttsProvider.speak('Color detection stopped');
      HapticFeedback.lightImpact();
    }
  }

  void _announceColorChange(String colorName) async {
    if (colorName != _lastAnnouncedColor && colorName.isNotEmpty) {
      _lastAnnouncedColor = colorName;
      final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
      await ttsProvider.speak('$colorName detected');
      HapticFeedback.mediumImpact();
    }
  }

  String _getColorName(int r, int g, int b) {
    // Simple color detection logic
    if (r > 200 && g < 100 && b < 100) return 'Red';
    if (r < 100 && g > 200 && b < 100) return 'Green';
    if (r < 100 && g < 100 && b > 200) return 'Blue';
    if (r > 200 && g > 200 && b < 100) return 'Yellow';
    if (r > 200 && g < 100 && b > 200) return 'Magenta';
    if (r < 100 && g > 200 && b > 200) return 'Cyan';
    if (r > 180 && g > 180 && b > 180) return 'White';
    if (r < 80 && g < 80 && b < 80) return 'Black';
    if (r > 150 && g > 100 && b < 100) return 'Orange';
    if (r > 100 && g < 100 && b > 100) return 'Purple';
    return 'Unknown color';
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 DEBUG: ColorDetectionDetails build() called - _isDetecting: $_isDetecting');
    return Container(
      color: Colors.yellow.withOpacity(0.3), // DEBUG: Temporary background
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AccessibleCard(
          backgroundColor: Colors.red.withOpacity(0.1), // DEBUG: Temporary background
          child: Consumer<WebSocketProvider>(
            builder: (context, websocketProvider, child) {
              debugPrint('🎨 DEBUG: Consumer builder called - connected: ${websocketProvider.isConnected}, data: ${websocketProvider.data}');
              // Update color data when detecting
              if (_isDetecting && websocketProvider.data != null) {
                final r = websocketProvider.r ?? 0;
                final g = websocketProvider.g ?? 0;
                final b = websocketProvider.b ?? 0;
                
                final colorName = _getColorName(r, g, b);
                if (colorName != _lastDetectedColor) {
                  _lastDetectedColor = colorName;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _announceColorChange(colorName);
                  });
                }
              }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with collapse button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Color Detection',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onCollapse,
                      icon: const Icon(Icons.keyboard_arrow_up),
                      tooltip: 'Collapse section',
                      iconSize: 32,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.marginMedium),
                
                // Color Display Area
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: websocketProvider.currentColor ?? AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isDetecting ? Icons.palette : Icons.palette_outlined,
                          size: 40,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),
                        Text(
                          _lastDetectedColor,
                          style: AppTextStyles.heading4.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppDimensions.marginMedium),
                
                // RGB Values Display
                if (websocketProvider.data != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRGBValue('R', websocketProvider.r ?? 0, Colors.red),
                      _buildRGBValue('G', websocketProvider.g ?? 0, Colors.green),
                      _buildRGBValue('B', websocketProvider.b ?? 0, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                ],
                
                // Connection Status
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: websocketProvider.isConnected 
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        websocketProvider.isConnected ? Icons.wifi : Icons.wifi_off,
                        color: websocketProvider.isConnected ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.marginSmall),
                      Text(
                        websocketProvider.isConnected ? 'Connected' : 'Disconnected',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: websocketProvider.isConnected ? AppColors.success : AppColors.error,
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
                      _isDetecting ? 'Stop Detection' : 'Start Detection',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
    );
  }

  Widget _buildRGBValue(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.marginXSmall),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
            vertical: AppDimensions.paddingXSmall,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Text(
            value.toString(),
            style: AppTextStyles.heading4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
