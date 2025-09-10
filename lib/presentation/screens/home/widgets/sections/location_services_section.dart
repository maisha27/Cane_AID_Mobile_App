import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/services/geocoding_service.dart';
import '../../../../widgets/common/accessible_card.dart';
import '../../../../providers/websocket_provider.dart';
import '../../../../providers/tts_provider.dart';
import '../section_types.dart';

/// Smart Location Services Card with Content Transition
/// Click to start auto-detection and show GPS coordinates with place names
class LocationServicesSection extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onCollapse;
  
  const LocationServicesSection({
    super.key,
    required this.isExpanded,
    this.onTap,
    this.onCollapse,
  });

  @override
  State<LocationServicesSection> createState() => _LocationServicesSectionState();
}

class _LocationServicesSectionState extends State<LocationServicesSection> {
  String _lastAnnouncedLocation = '';
  bool _hasStartedDetection = false;
  GeocodingResult? _cachedLocation;
  bool _isLoadingLocation = false;

  @override
  void didUpdateWidget(LocationServicesSection oldWidget) {
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
      _lastAnnouncedLocation = '';
      _cachedLocation = null;
    }
  }

  void _announceDetectionStart() async {
    try {
      final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
      await ttsProvider.speak('Location detection started');
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  void _announceLocationFound(String placeName) async {
    if (placeName != _lastAnnouncedLocation && placeName.isNotEmpty) {
      _lastAnnouncedLocation = placeName;
      try {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        await ttsProvider.speak('Location found: $placeName');
        HapticFeedback.mediumImpact();
      } catch (e) {
        debugPrint('TTS error: $e');
      }
    }
  }

  void _announceNoLocation() async {
    if (_lastAnnouncedLocation != 'no_location_found') {
      _lastAnnouncedLocation = 'no_location_found';
      try {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        await ttsProvider.speak('No location found');
      } catch (e) {
        debugPrint('TTS error: $e');
      }
    }
  }

  void _announceLocationError() async {
    if (_lastAnnouncedLocation != 'location_error') {
      _lastAnnouncedLocation = 'location_error';
      try {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        await ttsProvider.speak('Unable to determine location');
      } catch (e) {
        debugPrint('TTS error: $e');
      }
    }
  }

  /// Fetch place name from coordinates using geocoding service
  Future<void> _fetchPlaceName(double latitude, double longitude) async {
    if (_isLoadingLocation) return;
    
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final result = await GeocodingService.getPlaceName(latitude, longitude);
      
      if (mounted) {
        setState(() {
          _cachedLocation = result;
          _isLoadingLocation = false;
        });

        // Announce the result
        if (result.isSuccess && result.placeName != null) {
          _announceLocationFound(result.placeName!);
        } else {
          _announceLocationError();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cachedLocation = GeocodingResult.error('Failed to get location');
          _isLoadingLocation = false;
        });
        _announceLocationError();
      }
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
            Icons.location_on,
            size: 80,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          flex: 2,
          child: Text(
            SectionType.location.title,
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
            'Get your location',
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
  /// Shows coordinates, place name, and loading states
  Widget _buildDetectionView() {
    return Consumer<WebSocketProvider>(
      key: const ValueKey('detection'),
      builder: (context, websocketProvider, child) {
        // Get GPS coordinates from WebSocket
        final latitude = websocketProvider.latitude;
        final longitude = websocketProvider.longitude;
        
        // Check if we have valid GPS data
        final hasGpsData = latitude != null && longitude != null;
        
        if (hasGpsData) {
          // Fetch place name if we don't have it cached or coordinates changed
          if (_cachedLocation == null && !_isLoadingLocation) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchPlaceName(latitude, longitude);
            });
          }
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Location status icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  ),
                ),
                child: Icon(
                  _isLoadingLocation 
                      ? Icons.hourglass_top 
                      : (_cachedLocation?.isSuccess == true 
                          ? Icons.location_on 
                          : Icons.location_off),
                  size: 30,
                  color: _cachedLocation?.isSuccess == true ? Colors.blue : Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              
              // GPS Coordinates
              Text(
                '${latitude.toStringAsFixed(4)}°N, ${longitude.toStringAsFixed(4)}°E',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Place name or loading/error state
              if (_isLoadingLocation)
                Text(
                  'Finding location...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                )
              else if (_cachedLocation?.isSuccess == true)
                Text(
                  _cachedLocation!.placeName!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              else if (_cachedLocation?.error != null)
                Text(
                  'Location lookup failed',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  'Location found',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          );
        } else {
          // No GPS data available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _announceNoLocation();
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
                'No location found',
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
