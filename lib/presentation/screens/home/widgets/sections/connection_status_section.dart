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

  /// Ensure WebSocket connection when connection status check starts
  Future<void> _ensureWebSocketConnection() async {
    debugPrint('🔗 DEBUG: Ensuring WebSocket connection for status check...');
    
    final websocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
    
    if (!websocketProvider.isConnected) {
      debugPrint('🔗 DEBUG: WebSocket not connected, attempting connection...');
      final success = await websocketProvider.connectToServer();
      
      if (success) {
        debugPrint('🔗 DEBUG: WebSocket connected successfully for status check!');
      } else {
        debugPrint('🔗 ERROR: Failed to connect WebSocket: ${websocketProvider.lastError}');
      }
    } else {
      debugPrint('🔗 DEBUG: WebSocket already connected for status check');
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

  void _announceConnectionStatus(ConnectionStatus status) async {
    String statusKey = '';
    String announcement = '';
    
    switch (status) {
      case ConnectionStatus.activeWithData:
        statusKey = 'active_with_data';
        announcement = 'Connection secured and active';
        break;
      case ConnectionStatus.connectedNoData:
        statusKey = 'connected_no_data';
        announcement = 'Connected but no data received';
        break;
      case ConnectionStatus.disconnected:
        statusKey = 'disconnected';
        announcement = 'Connection not established';
        break;
    }
    
    if (statusKey != _lastAnnouncedStatus) {
      _lastAnnouncedStatus = statusKey;
      try {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        await ttsProvider.speak(announcement);
        HapticFeedback.mediumImpact();
      } catch (e) {
        debugPrint('TTS error: $e');
      }
    }
  }

  /// Get connection status text
  String _getConnectionStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.activeWithData:
        return 'Active & Secure';
      case ConnectionStatus.connectedNoData:
        return 'Connected (No Data)';
      case ConnectionStatus.disconnected:
        return 'Not Connected';
    }
  }

  /// Get connection status color
  Color _getConnectionStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.activeWithData:
        return Colors.green;
      case ConnectionStatus.connectedNoData:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.red;
    }
  }

  /// Get connection status Bluetooth icon
  IconData _getConnectionStatusIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.activeWithData:
        return Icons.bluetooth_connected;
      case ConnectionStatus.connectedNoData:
        return Icons.bluetooth;
      case ConnectionStatus.disconnected:
        return Icons.bluetooth_disabled;
    }
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

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
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
            Icons.bluetooth,
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
        final connectionStatus = websocketProvider.getConnectionStatus();
        final serverUrl = websocketProvider.serverUrl;
        final lastError = websocketProvider.lastError;
        final lastDataReceived = websocketProvider.lastDataReceived;
        
        debugPrint('🔗 DEBUG: Connection Status - ${connectionStatus.toString()}, Last Data: $lastDataReceived');
        
        // Announce connection status
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _announceConnectionStatus(connectionStatus);
        });
        
        // Get status properties
        final statusText = _getConnectionStatusText(connectionStatus);
        final statusColor = _getConnectionStatusColor(connectionStatus);
        final statusIcon = _getConnectionStatusIcon(connectionStatus);
        final formattedServerUrl = _formatServerUrl(serverUrl);
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Connection status indicator circle
            Container(
              width: 80,
              height: 80,
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
                size: 40,
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
            
            // Connection details without server URL
            if (connectionStatus == ConnectionStatus.activeWithData)
              Text(
                'Data flowing normally',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              )
            else if (connectionStatus == ConnectionStatus.connectedNoData)
              Column(
                children: [
                  Text(
                    'Waiting for data...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (lastDataReceived != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Last data: ${_formatTimestamp(lastDataReceived)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              )
            else if (connectionStatus == ConnectionStatus.disconnected && lastError != null)
              Text(
                'Connection failed',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              )
            else if (connectionStatus == ConnectionStatus.disconnected)
              Text(
                'No device connected',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        );
      },
    );
  }
}
