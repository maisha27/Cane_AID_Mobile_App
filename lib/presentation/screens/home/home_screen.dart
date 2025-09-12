import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/dimensions.dart';
import '../../providers/tts_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'widgets/sections/color_detection_section.dart';
import 'widgets/sections/obstacle_detection_section.dart';
import 'widgets/sections/location_services_section.dart';
import 'widgets/sections/connection_status_section.dart';
import '../../providers/websocket_provider.dart';

/// Main dashboard screen with voice-guided navigation
/// Provides access to all app features with accessibility support
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isColorDetectionExpanded = false;
  bool _isObstacleDetectionExpanded = false;
  bool _isLocationServicesExpanded = false;
  bool _isConnectionStatusExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _announceScreenEntry();
    _initializeWebSocketConnection();
  }

  /// Initialize WebSocket connection automatically when home screen loads
  Future<void> _initializeWebSocketConnection() async {
    debugPrint('🔗 DEBUG: Initializing WebSocket connection...');
    
    // Get WebSocket provider
    final websocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
    
    // Connect if not already connected
    if (!websocketProvider.isConnected) {
      debugPrint('🔗 DEBUG: WebSocket not connected, attempting connection...');
      final success = await websocketProvider.connectToServer();
      
      if (success) {
        debugPrint('🔗 DEBUG: WebSocket connection successful!');
      } else {
        debugPrint('🔗 ERROR: WebSocket connection failed: ${websocketProvider.lastError}');
      }
    } else {
      debugPrint('🔗 DEBUG: WebSocket already connected');
    }
  }

  void _toggleColorDetection() {
    debugPrint('🔍 DEBUG: _toggleColorDetection() called - current expanded state: $_isColorDetectionExpanded');
    setState(() {
      _isColorDetectionExpanded = !_isColorDetectionExpanded;
    });
    debugPrint('🔍 DEBUG: _toggleColorDetection() finished - new expanded state: $_isColorDetectionExpanded');
    HapticFeedback.lightImpact();
  }

  void _collapseColorDetection() {
    debugPrint('🔍 DEBUG: _collapseColorDetection() called');
    setState(() {
      _isColorDetectionExpanded = false;
    });
  }

  void _toggleObstacleDetection() {
    debugPrint('🔍 DEBUG: _toggleObstacleDetection() called - current expanded state: $_isObstacleDetectionExpanded');
    setState(() {
      _isObstacleDetectionExpanded = !_isObstacleDetectionExpanded;
    });
    debugPrint('🔍 DEBUG: _toggleObstacleDetection() finished - new expanded state: $_isObstacleDetectionExpanded');
    HapticFeedback.lightImpact();
  }

  void _collapseObstacleDetection() {
    debugPrint('🔍 DEBUG: _collapseObstacleDetection() called');
    setState(() {
      _isObstacleDetectionExpanded = false;
    });
  }

  void _toggleLocationServices() {
    debugPrint('🔍 DEBUG: _toggleLocationServices() called - current expanded state: $_isLocationServicesExpanded');
    setState(() {
      _isLocationServicesExpanded = !_isLocationServicesExpanded;
    });
    debugPrint('🔍 DEBUG: _toggleLocationServices() finished - new expanded state: $_isLocationServicesExpanded');
    HapticFeedback.lightImpact();
  }

  void _collapseLocationServices() {
    debugPrint('🔍 DEBUG: _collapseLocationServices() called');
    setState(() {
      _isLocationServicesExpanded = false;
    });
  }

  void _toggleConnectionStatus() {
    debugPrint('🔍 DEBUG: _toggleConnectionStatus() called - current expanded state: $_isConnectionStatusExpanded');
    setState(() {
      _isConnectionStatusExpanded = !_isConnectionStatusExpanded;
    });
    debugPrint('🔍 DEBUG: _toggleConnectionStatus() finished - new expanded state: $_isConnectionStatusExpanded');
    HapticFeedback.lightImpact();
  }

  void _collapseConnectionStatus() {
    debugPrint('🔍 DEBUG: _collapseConnectionStatus() called');
    setState(() {
      _isConnectionStatusExpanded = false;
    });
  }

  void _announceScreenEntry() async {
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        final l10n = AppLocalizations.of(context)!;
        
        await ttsProvider.announceScreenEntry(l10n.homeScreen);
        
        // Announce available features
        await Future.delayed(const Duration(milliseconds: 1000));
        await ttsProvider.speak('Four features available: Color detection, Obstacle detection, Connection to Cane AID, and Location services.');
      } catch (e) {
        debugPrint('TTS announcement error: $e');
      }
      
      HapticFeedback.lightImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.textLight,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
        actions: [
          // Add logo in app bar
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.backgroundLight,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/Cane Aid Logo - Soft Colors.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.accessibility_new,
                      size: 20,
                      color: AppColors.primary,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Semantics(
          label: 'Home screen with four main features',
          child: Column(
            children: [
              // Top row
              Expanded(
                child: Row(
                  children: [
                    // Top Left - Color Detection (Smart Section)
                    Expanded(
                      child: ColorDetectionSection(
                        isExpanded: _isColorDetectionExpanded,
                        onTap: _toggleColorDetection,
                        onCollapse: _collapseColorDetection,
                      ),
                    ),
                    // Vertical divider
                    Container(
                      width: 2,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    // Top Right - Obstacle Detection (Smart Section)
                    Expanded(
                      child: ObstacleDetectionSection(
                        isExpanded: _isObstacleDetectionExpanded,
                        onTap: _toggleObstacleDetection,
                        onCollapse: _collapseObstacleDetection,
                      ),
                    ),
                  ],
                ),
              ),
              // Horizontal divider
              Container(
                height: 2,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              // Bottom row
              Expanded(
                child: Row(
                  children: [
                    // Bottom Left - Connection Status (Smart Section)
                    Expanded(
                      child: ConnectionStatusSection(
                        isExpanded: _isConnectionStatusExpanded,
                        onTap: _toggleConnectionStatus,
                        onCollapse: _collapseConnectionStatus,
                      ),
                    ),
                    // Vertical divider
                    Container(
                      width: 2,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    // Bottom Right - Location Services (Smart Section)
                    Expanded(
                      child: LocationServicesSection(
                        isExpanded: _isLocationServicesExpanded,
                        onTap: _toggleLocationServices,
                        onCollapse: _collapseLocationServices,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
