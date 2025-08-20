import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../providers/tts_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Main dashboard screen with voice-guided navigation
/// Provides access to all app features with accessibility support
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _announceScreenEntry();
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
        await ttsProvider.speak('Four features available: Color detection, Distance detection, Location sharing, and Bluetooth connection.');
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
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(
              Icons.settings,
              color: AppColors.textLight,
              semanticLabel: 'Settings',
            ),
            tooltip: l10n.settings,
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
                    // Top Left - Color Detection
                    Expanded(
                      child: _buildFullSectionCard(
                        icon: Icons.color_lens,
                        title: l10n.colorDetection,
                        subtitle: l10n.colorDetectionSubtitle,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.colorDetection),
                        semanticLabel: '${l10n.colorDetection} feature. ${l10n.colorDetectionSubtitle}.',
                      ),
                    ),
                    // Vertical divider
                    Container(
                      width: 2,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    // Top Right - Distance Detection (Obstacle Detection)
                    Expanded(
                      child: _buildFullSectionCard(
                        icon: Icons.visibility,
                        title: l10n.distanceDetection,
                        subtitle: l10n.distanceDetectionSubtitle,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.distanceDetection),
                        semanticLabel: '${l10n.distanceDetection} feature. ${l10n.distanceDetectionSubtitle}.',
                      ),
                    ),
                  ],
                ),
              ),
              // Horizontal divider
              Container(
                height: 2,
                color: AppColors.primary.withOpacity(0.3),
              ),
              // Bottom row
              Expanded(
                child: Row(
                  children: [
                    // Bottom Left - Location Services (GPS)
                    Expanded(
                      child: _buildFullSectionCard(
                        icon: Icons.location_on,
                        title: l10n.locationServices,
                        subtitle: l10n.locationServicesSubtitle,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.location),
                        semanticLabel: '${l10n.locationServices} feature. ${l10n.locationServicesSubtitle}.',
                      ),
                    ),
                    // Vertical divider
                    Container(
                      width: 2,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    // Bottom Right - Bluetooth Connection
                    Expanded(
                      child: _buildFullSectionCard(
                        icon: Icons.bluetooth,
                        title: l10n.deviceConnection,
                        subtitle: l10n.deviceConnectionSubtitle,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.bluetooth),
                        semanticLabel: '${l10n.deviceConnection} feature. ${l10n.deviceConnectionSubtitle}.',
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

  Widget _buildFullSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required String semanticLabel,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          label: semanticLabel,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  ),
                  child: Icon(
                    icon,
                    size: AppDimensions.iconLarge,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppDimensions.marginMedium),
                Text(
                  title,
                  style: AppTextStyles.heading4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.marginSmall),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
