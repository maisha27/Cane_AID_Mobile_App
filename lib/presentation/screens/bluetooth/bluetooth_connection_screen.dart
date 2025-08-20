import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/accessible_button.dart';
import '../../widgets/common/accessible_card.dart';
import '../../providers/bluetooth_provider.dart';
import '../../providers/tts_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Bluetooth connection screen for ESP32 device pairing
/// Handles device discovery, connection, and status management
class BluetoothConnectionScreen extends StatefulWidget {
  const BluetoothConnectionScreen({super.key});

  @override
  State<BluetoothConnectionScreen> createState() => _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState extends State<BluetoothConnectionScreen> {
  @override
  void initState() {
    super.initState();
    _announceScreenEntry();
    _initializeBluetooth();
  }

  void _announceScreenEntry() async {
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        final l10n = AppLocalizations.of(context)!;
        
        await ttsProvider.announceScreenEntry(l10n.bluetoothConnectionScreen);
        
        await Future.delayed(const Duration(milliseconds: 1000));
        await ttsProvider.speak('ESP32 ${l10n.deviceConnection}');
      } catch (e) {
        debugPrint('TTS announcement error: $e');
      }
    });
  }

  void _initializeBluetooth() async {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    
    if (!bluetoothProvider.isInitialized) {
      await bluetoothProvider.initialize();
    }
    
    // Check if Bluetooth is enabled
    final isEnabled = await bluetoothProvider.isBluetoothEnabled();
    if (!isEnabled) {
      _showBluetoothDisabledDialog();
    }
  }

  void _showBluetoothDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Bluetooth Disabled',
          style: AppTextStyles.heading4,
        ),
        content: Text(
          'Please enable Bluetooth to connect to your ESP32 device.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          AccessibleButton(
            onPressed: () => Navigator.of(context).pop(),
            semanticLabel: 'Cancel Bluetooth enable request',
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          AccessibleButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
              await bluetoothProvider.turnOnBluetooth();
            },
            semanticLabel: 'Enable Bluetooth',
            child: Text(
              'Enable',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        title: Text(
          l10n.bluetoothConnection,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textLight,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<BluetoothProvider, TTSProvider>(
        builder: (context, bluetoothProvider, ttsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connection Status
                _buildConnectionStatus(bluetoothProvider, ttsProvider),
                
                const SizedBox(height: AppDimensions.marginLarge),
                
                // Control Buttons
                _buildControlButtons(bluetoothProvider, ttsProvider),
                
                const SizedBox(height: AppDimensions.marginLarge),
                
                // Device List
                _buildDeviceList(bluetoothProvider, ttsProvider),
                
                const SizedBox(height: AppDimensions.marginLarge),
                
                // Paired Devices
                _buildPairedDevices(bluetoothProvider, ttsProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatus(BluetoothProvider bluetoothProvider, TTSProvider ttsProvider) {
    final l10n = AppLocalizations.of(context)!;
    final isConnected = bluetoothProvider.isConnected;
    final statusColor = isConnected ? AppColors.success : AppColors.error;
    
    return AccessibleCard(
      semanticLabel: l10n.connectionStatus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                color: statusColor,
                size: AppDimensions.iconLarge,
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.connectionStatus,
                      style: AppTextStyles.heading4,
                    ),
                    Text(
                      isConnected ? l10n.connected : l10n.disconnected,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isConnected)
                AccessibleButton(
                  onPressed: () {
                    bluetoothProvider.disconnect();
                    ttsProvider.announceBluetoothStatus(false);
                  },
                  semanticLabel: l10n.disconnect,
                  backgroundColor: AppColors.error,
                  child: Text(
                    l10n.disconnect,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ),
            ],
          ),
          
          if (bluetoothProvider.lastError != null) ...[
            const SizedBox(height: AppDimensions.marginMedium),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: AppDimensions.iconMedium,
                  ),
                  const SizedBox(width: AppDimensions.marginSmall),
                  Expanded(
                    child: Text(
                      bluetoothProvider.lastError!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButtons(BluetoothProvider bluetoothProvider, TTSProvider ttsProvider) {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        Expanded(
          child: AccessibleButton(
            onPressed: bluetoothProvider.isScanning 
                ? null 
                : () async {
                    await bluetoothProvider.startScan();
                    ttsProvider.speak(l10n.scanning);
                  },
            semanticLabel: l10n.scan,
            backgroundColor: bluetoothProvider.isScanning 
                ? AppColors.textSecondary 
                : AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bluetoothProvider.isScanning) ...[
                  SizedBox(
                    width: AppDimensions.iconSmall,
                    height: AppDimensions.iconSmall,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textLight),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginSmall),
                ],
                Icon(
                  Icons.search,
                  size: AppDimensions.iconMedium,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: AppDimensions.marginSmall),
                Flexible(
                  child: Text(
                    bluetoothProvider.isScanning ? l10n.scanning : l10n.scan,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
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
            onPressed: bluetoothProvider.isScanning 
                ? () async {
                    await bluetoothProvider.stopScan();
                    ttsProvider.speak(l10n.stop);
                  } 
                : null,
            semanticLabel: l10n.stop,
            backgroundColor: bluetoothProvider.isScanning 
                ? AppColors.accent 
                : AppColors.textSecondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stop,
                  size: AppDimensions.iconMedium,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: AppDimensions.marginSmall),
                Flexible(
                  child: Text(
                    l10n.stop,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
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

  Widget _buildDeviceList(BluetoothProvider bluetoothProvider, TTSProvider ttsProvider) {
    final devices = bluetoothProvider.discoveredDevices;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discovered Devices',
          style: AppTextStyles.heading4,
          semanticsLabel: 'Discovered ESP32 devices section',
        ),
        const SizedBox(height: AppDimensions.marginMedium),
        
        if (devices.isEmpty) ...[
          AccessibleCard(
            semanticLabel: 'No devices found',
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    size: AppDimensions.iconLarge,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                  Text(
                    'No ESP32 devices found',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Make sure your device is powered on and in pairing mode',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          ...devices.map((device) => _buildDeviceCard(device, bluetoothProvider, ttsProvider)),
        ],
      ],
    );
  }

  Widget _buildDeviceCard(fbp.BluetoothDevice device, BluetoothProvider bluetoothProvider, TTSProvider ttsProvider) {
    final deviceName = device.platformName.isNotEmpty ? device.platformName : 'Unknown Device';
    final isConnecting = bluetoothProvider.isConnecting;
    final isConnected = bluetoothProvider.connectedDevice?.remoteId == device.remoteId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: AccessibleCard(
        onTap: isConnecting || isConnected 
            ? null 
            : () async {
                final success = await bluetoothProvider.connectToDevice(device);
                if (success) {
                  ttsProvider.announceBluetoothStatus(true);
                } else {
                  ttsProvider.announceError('Failed to connect to $deviceName');
                }
              },
        semanticLabel: 'ESP32 device $deviceName, tap to connect',
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: isConnected 
                    ? AppColors.success.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(
                isConnected 
                    ? Icons.bluetooth_connected 
                    : Icons.bluetooth,
                color: isConnected ? AppColors.success : AppColors.primary,
                size: AppDimensions.iconMedium,
              ),
            ),
            const SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: AppTextStyles.bodyMedium,
                  ),
                  Text(
                    device.remoteId.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (isConnected)
                    Text(
                      'Connected',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (isConnecting) ...[
              SizedBox(
                width: AppDimensions.iconMedium,
                height: AppDimensions.iconMedium,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ] else if (!isConnected) ...[
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: AppDimensions.iconMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPairedDevices(BluetoothProvider bluetoothProvider, TTSProvider ttsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paired Devices',
          style: AppTextStyles.heading4,
          semanticsLabel: 'Paired ESP32 devices section',
        ),
        const SizedBox(height: AppDimensions.marginMedium),
        
        FutureBuilder<List<fbp.BluetoothDevice>>(
          future: bluetoothProvider.getPairedDevices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return AccessibleCard(
                semanticLabel: 'No paired devices',
                child: Center(
                  child: Text(
                    'No paired ESP32 devices',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }
            
            return Column(
              children: snapshot.data!.map((device) => 
                _buildDeviceCard(device, bluetoothProvider, ttsProvider)
              ).toList(),
            );
          },
        ),
      ],
    );
  }
}
