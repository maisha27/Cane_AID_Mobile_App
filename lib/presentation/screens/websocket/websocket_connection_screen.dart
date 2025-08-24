import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/dimensions.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/common/accessible_card.dart';
import '../../widgets/common/accessible_button.dart';
import '../../providers/websocket_provider.dart';
import '../../providers/tts_provider.dart';

/// WebSocket connection screen for ESP32 communication via laptop bridge
/// Replaces Bluetooth connection screen for server-based connectivity
class WebSocketConnectionScreen extends StatefulWidget {
  const WebSocketConnectionScreen({super.key});

  @override
  State<WebSocketConnectionScreen> createState() => _WebSocketConnectionScreenState();
}

class _WebSocketConnectionScreenState extends State<WebSocketConnectionScreen> {
  final TextEditingController _serverUrlController = TextEditingController();
  bool _isCustomUrl = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceScreenEntry();
      _initializeServerUrl();
    });
  }

  void _announceScreenEntry() async {
    try {
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        await ttsProvider.announceScreenEntry(l10n.bluetoothConnectionScreen);
        
        await Future.delayed(const Duration(milliseconds: 1000));
        await ttsProvider.speak('Connect to ESP32 server on laptop');
      }
    } catch (e) {
      debugPrint('TTS announcement error: $e');
    }
    
    HapticFeedback.lightImpact();
  }

  void _initializeServerUrl() {
    final wsProvider = Provider.of<WebSocketProvider>(context, listen: false);
    _serverUrlController.text = wsProvider.serverUrl ?? 'ws://192.168.1.100:8080/cane-aid';
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'ESP32 Server Connection',
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
      body: Consumer<WebSocketProvider>(
        builder: (context, wsProvider, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Connection Status Card
                  _buildConnectionStatusCard(wsProvider, l10n),
                  
                  const SizedBox(height: AppDimensions.marginMedium),
                  
                  // Server Configuration Card
                  _buildServerConfigCard(wsProvider, l10n),
                  
                  const SizedBox(height: AppDimensions.marginMedium),
                  
                  // Connection Controls
                  _buildConnectionControls(wsProvider, l10n),
                  
                  const SizedBox(height: AppDimensions.marginMedium),
                  
                  // Latest Data Card
                  _buildLatestDataCard(wsProvider, l10n),
                  
                  const SizedBox(height: AppDimensions.marginMedium),
                  
                  // Connection Statistics
                  _buildStatisticsCard(wsProvider, l10n),
                  
                  const Spacer(),
                  
                  // Help Text
                  _buildHelpCard(l10n),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatusCard(WebSocketProvider wsProvider, AppLocalizations l10n) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (wsProvider.isConnected) {
      statusColor = AppColors.success;
      statusIcon = Icons.wifi;
      statusText = l10n.connected;
    } else if (wsProvider.isConnecting) {
      statusColor = AppColors.warning;
      statusIcon = Icons.wifi_off;
      statusText = 'Connecting...';
    } else {
      statusColor = AppColors.error;
      statusIcon = Icons.wifi_off;
      statusText = l10n.disconnected;
    }

    return AccessibleCard(
      semanticLabel: 'Connection status: $statusText',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.connectionStatus,
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: AppDimensions.iconMedium,
                ),
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (wsProvider.serverUrl != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        wsProvider.serverUrl!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (wsProvider.lastError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Error: ${wsProvider.lastError}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServerConfigCard(WebSocketProvider wsProvider, AppLocalizations l10n) {
    return AccessibleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Server Configuration',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          
          // Custom URL toggle
          Row(
            children: [
              Checkbox(
                value: _isCustomUrl,
                onChanged: (value) {
                  setState(() {
                    _isCustomUrl = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.marginSmall),
              Text(
                'Use custom server URL',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          
          if (_isCustomUrl) ...[
            const SizedBox(height: AppDimensions.marginMedium),
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                hintText: 'ws://192.168.1.100:8080/cane-aid',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              style: AppTextStyles.bodyMedium,
            ),
          ],
          
          const SizedBox(height: AppDimensions.marginMedium),
          
          // Quick connection presets
          Text(
            'Quick Connect:',
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          
          Wrap(
            spacing: AppDimensions.marginSmall,
            children: [
              _buildQuickConnectChip('Local (192.168.1.100)', 'ws://192.168.1.100:8080/cane-aid'),
              _buildQuickConnectChip('Localhost', 'ws://localhost:8080/cane-aid'),
              _buildQuickConnectChip('WiFi Hotspot', 'ws://192.168.43.1:8080/cane-aid'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickConnectChip(String label, String url) {
    return ActionChip(
      label: Text(
        label,
        style: AppTextStyles.bodySmall,
      ),
      onPressed: () {
        setState(() {
          _serverUrlController.text = url;
          _isCustomUrl = true;
        });
      },
      backgroundColor: AppColors.surface,
      side: BorderSide(color: AppColors.primary, width: 1),
    );
  }

  Widget _buildConnectionControls(WebSocketProvider wsProvider, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: AccessibleButton(
            onPressed: wsProvider.isConnecting
                ? null
                : () => _connectToServer(wsProvider),
            backgroundColor: wsProvider.isConnected
                ? AppColors.warning
                : AppColors.primary,
            semanticLabel: wsProvider.isConnected
                ? 'Reconnect to server'
                : 'Connect to server',
            child: Text(
              wsProvider.isConnected
                  ? 'Reconnect'
                  : wsProvider.isConnecting
                      ? 'Connecting...'
                      : 'Connect',
              style: AppTextStyles.buttonMedium,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.marginMedium),
        Expanded(
          child: AccessibleButton(
            onPressed: wsProvider.isConnected
                ? () => _disconnectFromServer(wsProvider)
                : null,
            backgroundColor: AppColors.error,
            semanticLabel: 'Disconnect from server',
            child: Text(
              l10n.disconnect,
              style: AppTextStyles.buttonMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestDataCard(WebSocketProvider wsProvider, AppLocalizations l10n) {
    return AccessibleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Sensor Data',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          
          if (wsProvider.latestData != null) ...[
            Text(
              wsProvider.getDataSummary(),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              'Received: ${wsProvider.latestData!.timestamp}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppDimensions.marginMedium),
            
            // Individual sensor data
            if (wsProvider.latestColorData != null) ...[
              _buildSensorDataRow(
                'Color',
                'RGB(${wsProvider.latestColorData!.r}, ${wsProvider.latestColorData!.g}, ${wsProvider.latestColorData!.b})',
                Icons.palette,
                AppColors.primary,
              ),
            ],
            
            if (wsProvider.latestDistanceData != null) ...[
              _buildSensorDataRow(
                'Distance',
                '${wsProvider.latestDistanceData!.distance.toStringAsFixed(1)} cm',
                Icons.straighten,
                AppColors.warning,
              ),
            ],
            
            if (wsProvider.latestGPSData != null) ...[
              _buildSensorDataRow(
                'Location',
                wsProvider.latestGPSData!.coordinatesString,
                Icons.location_on,
                AppColors.success,
              ),
            ],
          ] else ...[
            Text(
              'No sensor data received yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              'Make sure ESP32 is connected to laptop and bridge server is running',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSensorDataRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: AppDimensions.iconSmall,
          ),
          const SizedBox(width: AppDimensions.marginSmall),
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(WebSocketProvider wsProvider, AppLocalizations l10n) {
    final stats = wsProvider.getConnectionStats();
    
    return AccessibleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connection Statistics',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Messages', '${stats['totalMessages'] ?? 0}'),
              ),
              Expanded(
                child: _buildStatItem('Successful', '${stats['successfulParses'] ?? 0}'),
              ),
              Expanded(
                child: _buildStatItem('Errors', '${stats['errorParses'] ?? 0}'),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.marginMedium),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Reconnects', '${stats['providerReconnectAttempts'] ?? 0}'),
              ),
              Expanded(
                child: _buildStatItem('History', '${stats['dataHistoryCount'] ?? 0}'),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHelpCard(AppLocalizations l10n) {
    return AccessibleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: AppDimensions.iconSmall,
              ),
              const SizedBox(width: AppDimensions.marginSmall),
              Text(
                'Connection Help',
                style: AppTextStyles.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            '• Ensure ESP32 is connected to laptop via Bluetooth\n'
            '• Start the bridge server on your laptop\n'
            '• Connect phone and laptop to same WiFi network\n'
            '• Use laptop\'s IP address in server URL\n'
            '• Default port is 8080, path is /cane-aid',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToServer(WebSocketProvider wsProvider) async {
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    
    try {
      await ttsProvider.speak('Connecting to ESP32 server');
      
      String serverUrl = _isCustomUrl 
          ? _serverUrlController.text.trim()
          : wsProvider.serverUrl ?? 'ws://192.168.1.100:8080/cane-aid';
      
      if (_isCustomUrl) {
        wsProvider.updateServerUrl(serverUrl);
      }
      
      final success = await wsProvider.connectToServer(
        customUrl: _isCustomUrl ? serverUrl : null,
      );
      
      if (mounted) {
        if (success) {
          await ttsProvider.speak('Connected to ESP32 server successfully');
          HapticFeedback.heavyImpact();
        } else {
          await ttsProvider.speak('Connection failed. Check server and network settings');
          HapticFeedback.lightImpact();
        }
      }
    } catch (e) {
      debugPrint('Connection error: $e');
      if (mounted) {
        await ttsProvider.speak('Connection error occurred');
      }
    }
  }

  Future<void> _disconnectFromServer(WebSocketProvider wsProvider) async {
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    
    try {
      await ttsProvider.speak('Disconnecting from server');
      await wsProvider.disconnect();
      
      if (mounted) {
        await ttsProvider.speak('Disconnected from ESP32 server');
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Disconnection error: $e');
      if (mounted) {
        await ttsProvider.speak('Disconnection error occurred');
      }
    }
  }
}
