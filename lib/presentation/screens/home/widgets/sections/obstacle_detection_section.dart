import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../widgets/common/accessible_card.dart';
import '../../../../providers/websocket_provider.dart';
import '../../../../providers/tts_provider.dart';
import '../section_types.dart';

/// Smart Obstacle Detection Card with Content Transition
/// Click to start auto-detection and show distance data within same card boundaries
class ObstacleDetectionSection extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onCollapse;
  
  const ObstacleDetectionSection({
    super.key,
    required this.isExpanded,
    this.onTap,
    this.onCollapse,
  });

  @override
  State<ObstacleDetectionSection> createState() => _ObstacleDetectionSectionState();
}

class _ObstacleDetectionSectionState extends State<ObstacleDetectionSection> {
  String _lastAnnouncedStatus = '';
  bool _hasStartedDetection = false;
  
  // Detection threshold in centimeters
  static const double _obstacleThreshold = 50.0;

  @override
  void didUpdateWidget(ObstacleDetectionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-start detection when expanded
    if (!oldWidget.isExpanded && widget.isExpanded && !_hasStartedDetection) {
      _hasStartedDetection = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureWebSocketConnection();
        _announceDetectionStart();
      });
    }
    
    // Reset detection flag when collapsed
    if (oldWidget.isExpanded && !widget.isExpanded) {
      _hasStartedDetection = false;
      _lastAnnouncedStatus = '';
    }
  }

  /// Ensure WebSocket connection when obstacle detection starts
  Future<void> _ensureWebSocketConnection() async {
    debugPrint('🚧 DEBUG: Ensuring WebSocket connection for obstacle detection...');
    
    final websocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
    
    if (!websocketProvider.isConnected) {
      debugPrint('🚧 DEBUG: WebSocket not connected, attempting connection...');
      final success = await websocketProvider.connectToServer();
      
      if (success) {
        debugPrint('🚧 DEBUG: WebSocket connected successfully for obstacle detection!');
      } else {
        debugPrint('🚧 ERROR: Failed to connect WebSocket: ${websocketProvider.lastError}');
      }
    } else {
      debugPrint('🚧 DEBUG: WebSocket already connected for obstacle detection');
    }
  }

  void _announceDetectionStart() async {
    try {
      final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
      await ttsProvider.speak('Obstacle detection started');
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  void _announceObstacleDetection(double distance) async {
    final isObstacle = distance < _obstacleThreshold;
    final status = isObstacle ? 'obstacle_detected' : 'clear_path';
    
    if (status != _lastAnnouncedStatus) {
      _lastAnnouncedStatus = status;
      try {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        if (isObstacle) {
          await ttsProvider.speak('Obstacle detected at ${distance.toStringAsFixed(1)} centimeters');
        } else {
          await ttsProvider.speak('Clear path ahead');
        }
        HapticFeedback.mediumImpact();
      } catch (e) {
        debugPrint('TTS error: $e');
      }
    }
  }

  void _announceNoObstacle() async {
    if (_lastAnnouncedStatus != 'no_obstacle_detected') {
      _lastAnnouncedStatus = 'no_obstacle_detected';
      try {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        await ttsProvider.speak('No obstacle detected');
      } catch (e) {
        debugPrint('TTS error: $e');
      }
    }
  }

  /// Get obstacle status based on distance
  String _getObstacleStatus(double distance) {
    if (distance < _obstacleThreshold) {
      return 'Obstacle Detected';
    } else {
      return 'Clear Path';
    }
  }

  /// Get status color based on distance
  Color _getStatusColor(double distance) {
    if (distance < _obstacleThreshold) {
      return Colors.red; // Obstacle detected
    } else {
      return Colors.green; // Clear path
    }
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
            Icons.radar,
            size: 80,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          flex: 2,
          child: Text(
            SectionType.obstacleDetection.title,
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
            'Detect obstacles',
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
  /// Shows only distance value, status, and visual indicator
  Widget _buildDetectionView() {
    return Consumer<WebSocketProvider>(
      key: const ValueKey('detection'),
      builder: (context, websocketProvider, child) {
        // Get distance value from WebSocket
        final distance = websocketProvider.distance;
        
        // Check if we have valid distance data
        final hasDistanceData = distance != null;
        
        if (hasDistanceData) {
          // Get obstacle status and color
          final status = _getObstacleStatus(distance);
          final statusColor = _getStatusColor(distance);
          final isObstacle = distance < _obstacleThreshold;
          
          debugPrint('🚧 DEBUG: Distance Data - ${distance.toStringAsFixed(1)} cm, Status: $status');
          
          // Announce obstacle detection
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _announceObstacleDetection(distance);
          });
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status indicator circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: statusColor,
                    width: 3,
                  ),
                ),
                child: Icon(
                  isObstacle ? Icons.warning : Icons.check_circle,
                  size: 30,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 12),
              
              // Distance value
              Text(
                '${distance.toStringAsFixed(1)} cm',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Status text
              Text(
                status,
                style: AppTextStyles.bodySmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        } else {
          // No distance data available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _announceNoObstacle();
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
                'No obstacle detected',
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
