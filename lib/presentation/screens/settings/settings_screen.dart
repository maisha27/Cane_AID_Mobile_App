import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/common/accessible_card.dart';
import '../../providers/tts_provider.dart';

/// Settings screen with accessibility options
/// Allows users to configure app preferences including voice and caretaker settings
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
        await ttsProvider.announceScreenEntry(l10n.settingsScreen);
        
        // Announce purpose
        await Future.delayed(const Duration(milliseconds: 1000));
        await ttsProvider.speak(l10n.configureAppPreferences);
      }
    } catch (e) {
      debugPrint('TTS announcement error: $e');
    }
    
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.settings,
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
          label: 'Settings screen with configuration options',
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            children: [
              // App Settings Section
              _buildSectionHeader(l10n.appPreferences),
              _buildSettingsCard(
                icon: Icons.record_voice_over,
                title: l10n.voiceSettings,
                subtitle: l10n.voiceAndSpeech,
                onTap: () => Navigator.pushNamed(context, AppRoutes.voiceSettings),
                semanticLabel: '${l10n.voiceSettings}. ${l10n.voiceAndSpeech}.',
              ),
              _buildSettingsCard(
                icon: Icons.accessibility,
                title: l10n.accessibilityOptions,
                subtitle: 'High contrast, font size',
                onTap: () => Navigator.pushNamed(context, AppRoutes.accessibilitySettings),
                semanticLabel: '${l10n.accessibilityOptions}. Configure high contrast and font size.',
              ),

              const SizedBox(height: AppDimensions.marginLarge),

              // Connection Settings Section
              _buildSectionHeader(l10n.bluetoothSettings),
              _buildSettingsCard(
                icon: Icons.bluetooth,
                title: l10n.bluetoothConnection,
                subtitle: l10n.esp32DeviceManagement,
                onTap: () => Navigator.pushNamed(context, AppRoutes.bluetooth),
                semanticLabel: '${l10n.bluetoothConnection}. ${l10n.esp32DeviceManagement}.',
              ),

              const SizedBox(height: AppDimensions.marginLarge),

              // Emergency Contact Section
              _buildSectionHeader(l10n.emergencyContact),
              _buildSettingsCard(
                icon: Icons.contact_phone,
                title: l10n.caretakerContact,
                subtitle: l10n.emergencyContactInfo,
                onTap: () => Navigator.pushNamed(context, AppRoutes.caretakerSettings),
                semanticLabel: '${l10n.caretakerContact}. ${l10n.emergencyContactInfo}.',
              ),

              const SizedBox(height: AppDimensions.marginLarge),

              // Help & Support Section
              _buildSectionHeader(l10n.helpAndSupport),
              _buildSettingsCard(
                icon: Icons.help_outline,
                title: l10n.helpAndTutorial,
                subtitle: l10n.learnHowToUse,
                onTap: () => Navigator.pushNamed(context, AppRoutes.help),
                semanticLabel: '${l10n.helpAndTutorial}. ${l10n.learnHowToUse}.',
              ),
              _buildSettingsCard(
                icon: Icons.info_outline,
                title: l10n.about,
                subtitle: l10n.appVersionAndInfo,
                onTap: () => _showAboutDialog(),
                semanticLabel: '${l10n.aboutCaneAid}. ${l10n.appVersionAndInfo}.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.paddingSmall,
        bottom: AppDimensions.paddingSmall,
        top: AppDimensions.paddingMedium,
      ),
      child: Text(
        title,
        style: AppTextStyles.heading4.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required String semanticLabel,
  }) {
    return AccessibleCard(
      onTap: onTap,
      semanticLabel: semanticLabel,
      margin: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: AppDimensions.iconMedium,
            ),
          ),
          const SizedBox(width: AppDimensions.marginMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.marginXSmall),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: AppDimensions.iconSmall,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.aboutCaneAid),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cane AID v1.0.0'),
            const SizedBox(height: 8),
            Text(l10n.assistiveTechnology),
            const SizedBox(height: 8),
            Text(l10n.features),
            Text(l10n.colorDetectionViaEsp32),
            Text(l10n.distanceDetectionFeature),
            Text(l10n.gpsLocationSharing),
            Text('• Voice feedback in English'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}
