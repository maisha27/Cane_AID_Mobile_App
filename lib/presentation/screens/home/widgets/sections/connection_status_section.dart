import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../widgets/common/accessible_card.dart';
import '../../../../providers/websocket_provider.dart';
import '../../../../providers/tts_provider.dart';
import '../section_types.dart';

/// Smart Connection Status Card with Content Transition
/// Click to check connection status and show WebSocket connectivity state
class ConnectionStatusSection extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onCollapse;
  
  const ConnectionStatusSection({
    super.key,
    required this.isExpanded,
    this.onTap,
    this.onCollapse,
  });

  @override
  State<ConnectionStatusSection> createState() => _ConnectionStatusSectionState();
}

class _ConnectionStatusSectionState extends State<ConnectionStatusSection> {
  String _lastAnnouncedStatus = '';
  bool _hasStartedDetection = false;

  @override
  void didUpdateWidget(ConnectionStatusSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-start detection when expanded
    if (!oldWidget.isExpanded && widget.isExpanded && !_hasStartedDetection) {
      _hasStartedDetection = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _announceDetectionStart();
      });
    }
    
    // Reset detection flag when collapsed
    if (oldWidget.isExpanded && !widget.isExpanded) {
      _hasStartedDetection = false;
      _lastAnnouncedStatus = '';
    }
  }

  void _announceDetectionStart() async {
    try {
      final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
      await ttsProvider.speak('Checking connection status');
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  void _announceConnectionStatus(bool isConnected, String? serverUrl) async {
    final status = isConnected ? 'connected' : 'disconnected';
    
    if (status != _lastAnnouncedStatus) {
      _lastAnnouncedStatus = status;
      try {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        if (isConnected) {
          await ttsProvider.speak('Connected to Cane AID device');
        } else {
          await ttsProvider.speak('Not connected to Cane AID device');
        }
        HapticFeedback.mediumImpact();
      } catch (e) {
        debugPrint('TTS error: $e');
      }
    }
  }

  /// Get connection status text
  String _getConnectionStatusText(bool isConnected) {
    return isConnected ? 'Connected' : 'Not Connected';
  }

  /// Get connection status color
  Color _getConnectionStatusColor(bool isConnected) {
    return isConnected ? Colors.green : Colors.red;
  }

  /// Get connection status icon
  IconData _getConnectionStatusIcon(bool isConnected) {
    return isConnected ? Icons.check_circle : Icons.cancel;
  }

  /// Format server URL for display
  String _formatServerUrl(String? serverUrl) {
    if (serverUrl == null || serverUrl.isEmpty) {
      return 'No server configured';
    }
    
    // Extract host from WebSocket URL
    try {
      final uri = Uri.parse(serverUrl);
      return '${uri.host}:${uri.port}';
    } catch (e) {
      return serverUrl;
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
            Icons.wifi,
            size: 80,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          flex: 2,
          child: Text(
            SectionType.connection.title,
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
            'Check connection',
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
  /// Shows connection status, server info, and connectivity indicators
  Widget _buildDetectionView() {
    return Consumer<WebSocketProvider>(
      key: const ValueKey('detection'),
      builder: (context, websocketProvider, child) {
        // Get connection status from WebSocket provider
        final isConnected = websocketProvider.isConnected;
        final serverUrl = websocketProvider.serverUrl;
        final lastError = websocketProvider.lastError;
        
        // Announce connection status
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _announceConnectionStatus(isConnected, serverUrl);
        });
        
        // Get status properties
        final statusText = _getConnectionStatusText(isConnected);
        final statusColor = _getConnectionStatusColor(isConnected);
        final statusIcon = _getConnectionStatusIcon(isConnected);
        final formattedServerUrl = _formatServerUrl(serverUrl);
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Connection status indicator circle
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusColor,
                  width: 3,
                ),
              ),
              child: Icon(
                statusIcon,
                size: 80,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 12),
            
            // Connection status text
            Text(
              statusText,
              style: AppTextStyles.bodySmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Server URL or error information
            if (isConnected && serverUrl != null)
              Text(
                formattedServerUrl,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            else if (!isConnected && lastError != null)
              Text(
                'Connection failed',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              )
            else if (!isConnected)
              Text(
                'No device connected',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        );
      },
    );
  }
}
