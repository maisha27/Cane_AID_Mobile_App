import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/dimensions.dart';
import '../../widgets/common/accessible_card.dart';
import '../../widgets/common/accessible_button.dart';
import '../../providers/websocket_provider.dart';
import '../../providers/tts_provider.dart';

/// WebSocket testing screen to verify connection and data flow
/// This is a development screen for testing Phase 1 implementation
class WebSocketTestScreen extends StatefulWidget {
  const WebSocketTestScreen({super.key});

  @override
  State<WebSocketTestScreen> createState() => _WebSocketTestScreenState();
}

class _WebSocketTestScreenState extends State<WebSocketTestScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = 'ws://192.168.1.100:8080/cane-aid';
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'WebSocket Test',
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.textLight,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
      ),
      body: Consumer<WebSocketProvider>(
        builder: (context, wsProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Server URL Input
                AccessibleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Server URL',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: AppDimensions.marginSmall),
                      TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          hintText: 'ws://192.168.1.100:8080/cane-aid',
                          border: OutlineInputBorder(),
                        ),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppDimensions.marginMedium),
                
                // Connection Status
                AccessibleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connection Status',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: AppDimensions.marginSmall),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: wsProvider.isConnected
                                  ? Colors.green
                                  : wsProvider.isConnecting
                                      ? Colors.orange
                                      : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.marginSmall),
                          Expanded(
                            child: Text(
                              wsProvider.getConnectionStatusText(),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      if (wsProvider.lastError != null) ...[
                        const SizedBox(height: AppDimensions.marginSmall),
                        Text(
                          'Error: ${wsProvider.lastError}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: AppDimensions.marginMedium),
                
                // Connection Controls
                Row(
                  children: [
                    Expanded(
                      child: AccessibleButton(
                        onPressed: wsProvider.isConnecting
                            ? null
                            : () => _connectToServer(wsProvider),
                        backgroundColor: wsProvider.isConnected
                            ? Colors.orange
                            : AppColors.primary,
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
                    const SizedBox(width: AppDimensions.marginSmall),
                    Expanded(
                      child: AccessibleButton(
                        onPressed: wsProvider.isConnected
                            ? () => _disconnectFromServer(wsProvider)
                            : null,
                        backgroundColor: Colors.red,
                        child: Text(
                          'Disconnect',
                          style: AppTextStyles.buttonMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.marginMedium),
                
                // Send Test Message
                AccessibleButton(
                  onPressed: wsProvider.isConnected
                      ? () => _sendTestMessage(wsProvider)
                      : null,
                  child: Text(
                    'Send Test Message',
                    style: AppTextStyles.buttonMedium,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.marginMedium),
                
                // Latest Data
                AccessibleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest Sensor Data',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: AppDimensions.marginSmall),
                      Text(
                        wsProvider.getDataSummary(),
                        style: AppTextStyles.bodyMedium,
                      ),
                      if (wsProvider.latestData != null) ...[
                        const SizedBox(height: AppDimensions.marginSmall),
                        Text(
                          'Received: ${wsProvider.latestData!.timestamp}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: AppDimensions.marginMedium),
                
                // Connection Statistics
                AccessibleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: AppDimensions.marginSmall),
                      ...wsProvider.getConnectionStats().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _connectToServer(WebSocketProvider wsProvider) async {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
      await ttsProvider.speak('Connecting to server');
      
      final success = await wsProvider.connectToServer(customUrl: url);
      
      if (mounted) {
        if (success) {
          await ttsProvider.speak('Connected to ESP32 server successfully');
        } else {
          await ttsProvider.speak('Connection failed');
        }
      }
    }
  }

  Future<void> _disconnectFromServer(WebSocketProvider wsProvider) async {
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    await ttsProvider.speak('Disconnecting');
    
    await wsProvider.disconnect();
    await ttsProvider.speak('Disconnected from server');
  }

  Future<void> _sendTestMessage(WebSocketProvider wsProvider) async {
    final success = await wsProvider.sendMessage({
      'type': 'test',
      'message': 'Hello from Cane AID app',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    if (success) {
      await ttsProvider.speak('Test message sent');
    } else {
      await ttsProvider.speak('Failed to send message');
    }
  }
}
