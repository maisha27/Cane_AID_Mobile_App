import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/dimensions.dart';
import '../../widgets/common/accessible_button.dart';
import '../../providers/tts_provider.dart';

/// Voice settings screen for TTS configuration
/// Allows users to test and configure voice feedback options
class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  @override
  void initState() {
    super.initState();
    _announceScreenEntry();
  }

  void _announceScreenEntry() async {
    try {
      final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
      await ttsProvider.announceScreenEntry('Voice settings screen');
      
      await Future.delayed(const Duration(milliseconds: 1000));
      await ttsProvider.speak('Configure voice feedback and test speech settings');
    } catch (e) {
      debugPrint('TTS announcement error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        title: Text(
          'Voice Settings',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textLight,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<TTSProvider>(
        builder: (context, ttsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TTS Status
                _buildStatusSection(ttsProvider),
                
                const SizedBox(height: AppDimensions.marginLarge),
                
                // Test Section
                _buildTestSection(ttsProvider),
                
                const SizedBox(height: AppDimensions.marginLarge),
                
                // Announcement Settings
                _buildAnnouncementSettings(ttsProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusSection(TTSProvider ttsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voice Status',
          style: AppTextStyles.heading4,
          semanticsLabel: 'Voice status section',
        ),
        const SizedBox(height: AppDimensions.marginMedium),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: ttsProvider.isInitialized 
                  ? AppColors.success 
                  : AppColors.error,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                ttsProvider.isInitialized 
                    ? Icons.volume_up 
                    : Icons.volume_off,
                color: ttsProvider.isInitialized 
                    ? AppColors.success 
                    : AppColors.error,
                size: AppDimensions.iconMedium,
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ttsProvider.isInitialized 
                          ? 'Voice feedback enabled'
                          : 'Voice feedback disabled',
                      style: AppTextStyles.bodyMedium,
                    ),
                    Text(
                      'Language: English',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestSection(TTSProvider ttsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Voice',
          style: AppTextStyles.heading4,
          semanticsLabel: 'Test voice section',
        ),
        const SizedBox(height: AppDimensions.marginMedium),
        Row(
          children: [
            Expanded(
              child: AccessibleButton(
                onPressed: () => ttsProvider.testSpeech(),
                semanticLabel: 'Test voice with current settings',
                child: Text(
                  'Test Voice',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: AccessibleButton(
                onPressed: () => ttsProvider.stop(),
                semanticLabel: 'Stop current speech',
                backgroundColor: AppColors.error,
                child: Text(
                  'Stop',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnnouncementSettings(TTSProvider ttsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Announcements',
          style: AppTextStyles.heading4,
          semanticsLabel: 'Announcement settings section',
        ),
        const SizedBox(height: AppDimensions.marginMedium),
        
        _buildSwitchTile(
          'Button Press Announcements',
          'Announce when buttons are pressed',
          ttsProvider.announceButtonPresses,
          (value) => ttsProvider.setAnnounceButtonPresses(value),
        ),
        
        _buildSwitchTile(
          'Screen Change Announcements',
          'Announce when entering new screens',
          ttsProvider.announceScreenChanges,
          (value) => ttsProvider.setAnnounceScreenChanges(value),
        ),
        
        _buildSwitchTile(
          'Error Announcements',
          'Announce error messages',
          ttsProvider.announceErrors,
          (value) => ttsProvider.setAnnounceErrors(value),
        ),
        
        _buildSwitchTile(
          'Status Updates',
          'Announce status changes and notifications',
          ttsProvider.announceStatusUpdates,
          (value) => ttsProvider.setAnnounceStatusUpdates(value),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: '$title switch',
            value: value ? 'enabled' : 'disabled',
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
