import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../widgets/common/accessible_card.dart';
import '../../../../providers/websocket_provider.dart';
import '../../../../providers/tts_provider.dart';
import '../section_types.dart';

/// Smart Color Detection Card with Content Transition
/// Click to start auto-detection and show RGB data within same card boundaries
class ColorDetectionSection extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onCollapse;
  
  const ColorDetectionSection({
    super.key,
    required this.isExpanded,
    this.onTap,
    this.onCollapse,
  });

  @override
  State<ColorDetectionSection> createState() => _ColorDetectionSectionState();
}

class _ColorDetectionSectionState extends State<ColorDetectionSection> {
  String _lastAnnouncedColor = '';
  bool _hasStartedDetection = false;

  @override
  void didUpdateWidget(ColorDetectionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-start detection when expanded
    if (!oldWidget.isExpanded && widget.isExpanded && !_hasStartedDetection) {
      _hasStartedDetection = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _announceDetectionStart();
        _ensureWebSocketConnection();
      });
    }
    
    // Reset detection flag when collapsed
    if (oldWidget.isExpanded && !widget.isExpanded) {
      _hasStartedDetection = false;
      _lastAnnouncedColor = '';
    }
  }

  /// Ensure WebSocket is connected when color detection starts
  Future<void> _ensureWebSocketConnection() async {
    debugPrint('🎨 DEBUG: Ensuring WebSocket connection for color detection...');
    
    final websocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
    
    if (!websocketProvider.isConnected) {
      debugPrint('🎨 DEBUG: WebSocket not connected, attempting connection...');
      final success = await websocketProvider.connectToServer();
      
      if (success) {
        debugPrint('🎨 DEBUG: WebSocket connection successful for color detection!');
      } else {
        debugPrint('🎨 ERROR: WebSocket connection failed for color detection: ${websocketProvider.lastError}');
      }
    } else {
      debugPrint('🎨 DEBUG: WebSocket already connected for color detection');
    }
  }

  void _announceDetectionStart() async {
    try {
      final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
      await ttsProvider.speak('Color detection started');
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  void _announceColorDetection(String colorName) async {
    if (colorName != _lastAnnouncedColor && colorName.isNotEmpty && colorName != 'No color detected') {
      _lastAnnouncedColor = colorName;
      try {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        await ttsProvider.speak('Object is $colorName');
        HapticFeedback.mediumImpact();
      } catch (e) {
        debugPrint('TTS error: $e');
      }
    }
  }

  void _announceNoColor() async {
    if (_lastAnnouncedColor != 'no_color_detected') {
      _lastAnnouncedColor = 'no_color_detected';
      try {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        await ttsProvider.speak('No color detected');
      } catch (e) {
        debugPrint('TTS error: $e');
      }
    }
  }

  /// Simple color name detection
  String _getColorName(int r, int g, int b) {
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
  Widget build(BuildContext context) {
    return AccessibleCard(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(12.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: widget.isExpanded 
              ? _buildDetectionView() 
              : _buildInfoView(),
        ),
      ),
    );
  }

  /// Static info view (collapsed state)
  Widget _buildInfoView() {
    return Column(
      key: const ValueKey('info'),
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 2,
          child: Icon(
            Icons.palette,
            size: 80,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          flex: 2,
          child: Text(
            SectionType.colorDetection.title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          flex: 1,
          child: Text(
            'Detect colors',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Minimal detection view (expanded state)
  /// Shows only RGB values, color preview, and color name
  Widget _buildDetectionView() {
    return Consumer<WebSocketProvider>(
      key: const ValueKey('detection'),
      builder: (context, websocketProvider, child) {
        // Get RGB values from WebSocket
        final r = websocketProvider.r;
        final g = websocketProvider.g;
        final b = websocketProvider.b;
        
        // Check if we have valid color data
        final hasColorData = r != null && g != null && b != null;
        
        if (hasColorData) {
          // Create color and get name
          final color = Color.fromRGBO(r, g, b, 1.0);
          final colorName = _getColorName(r, g, b);
          
          // Announce color detection
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _announceColorDetection(colorName);
          });
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Color preview circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // RGB values
              Text(
                'RGB: $r, $g, $b',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Color name
              Text(
                colorName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        } else {
          // No color data available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _announceNoColor();
          });
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 80,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                'No color detected',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }
      },
    );
  }
}
