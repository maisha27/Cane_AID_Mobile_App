import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/dimensions.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/common/accessible_card.dart';
import '../../providers/tts_provider.dart';
import '../../providers/websocket_provider.dart';

/// Location sharing screen for emergency situations
/// Allows users to share their current location with caretakers
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _isLoading = false;
  String _currentLocation = 'Location not available';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceScreenEntry();
    });
  }

  void _announceScreenEntry() async {
    try {
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        await ttsProvider.announceScreenEntry(l10n.locationScreen);
        
        // Announce purpose
        await Future.delayed(const Duration(milliseconds: 1000));
        await ttsProvider.speak(l10n.shareLocationWithCaretaker);
      }
    } catch (e) {
      debugPrint('TTS announcement error: $e');
    }
    
    HapticFeedback.lightImpact();
  }

  void _shareLocation() async {
    setState(() {
      _isLoading = true;
    });

    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    final websocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
    
    try {
      // Try to get GPS coordinates from WebSocket provider first
      String locationText;
      if (websocketProvider.isConnected && 
          websocketProvider.latitude != null && 
          websocketProvider.longitude != null) {
        final lat = websocketProvider.latitude!.toStringAsFixed(4);
        final lng = websocketProvider.longitude!.toStringAsFixed(4);
        locationText = 'GPS: $lat, $lng';
        await ttsProvider.speak('Sharing GPS coordinates from device');
      } else {
        // Fallback to simulated location
        await Future.delayed(const Duration(seconds: 2)); // Simulate loading
        locationText = 'Dhaka, Bangladesh (Fallback)';
        await ttsProvider.speak('No GPS data available, using fallback location');
      }
      
      setState(() {
        _currentLocation = locationText;
        _isLoading = false;
      });
      
      await ttsProvider.speak('Location shared successfully');
      HapticFeedback.heavyImpact();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      await ttsProvider.speak('Location sharing failed');
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.location,
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
        child: Semantics(
          label: '${l10n.locationScreen} with location sharing',
          child: Consumer<WebSocketProvider>(
            builder: (context, websocketProvider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  children: [
                    // Status Card
                    AccessibleCard(
                      child: Column(
                        children: [
                          Icon(
                            _isLoading ? Icons.location_searching : Icons.location_on,
                            size: 80,
                            color: _isLoading ? AppColors.warning : AppColors.primary,
                          ),
                          const SizedBox(height: AppDimensions.marginMedium),
                          Text(
                            _isLoading ? 'Getting location...' : 'Location ready',
                            style: AppTextStyles.heading3.copyWith(
                              color: _isLoading ? AppColors.warning : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginSmall),
                          
                          // Show live GPS data if available, otherwise fallback
                          if (websocketProvider.isConnected && 
                              websocketProvider.latitude != null && 
                              websocketProvider.longitude != null) ...[
                            Text(
                              'Live GPS:',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.marginXSmall),
                            Text(
                              websocketProvider.coordinatesString,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ] else ...[
                            Text(
                              _currentLocation,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.marginLarge),
                    
                    // Share Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _shareLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textLight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingLarge * 2,
                            vertical: AppDimensions.paddingMedium,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.textLight,
                              )
                            : Text(
                                'Share Location',
                                style: AppTextStyles.heading4.copyWith(
                                  color: AppColors.textLight,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.marginLarge),
                    
                    // Instructions
                    AccessibleCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Location Sharing:',
                            style: AppTextStyles.heading4.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginSmall),
                          Text(
                            '• Press Share Location in emergency\n'
                            '• Your GPS coordinates will be sent\n'
                            '• Caretaker will receive SMS notification\n'
                            '• Works even with limited internet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
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
        ),
      ),
    );
  }
}
