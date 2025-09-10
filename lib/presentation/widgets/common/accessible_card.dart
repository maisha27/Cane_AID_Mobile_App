import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/dimensions.dart';
import '../../providers/tts_provider.dart';

/// Accessible card widget with voice feedback and proper touch targets
/// Provides consistent styling and accessibility features
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final Color? backgroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final bool announceOnTap;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.backgroundColor,
    this.elevation,
    this.padding,
    this.margin,
    this.border,
    this.announceOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: elevation ?? AppDimensions.cardElevation,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
      margin: margin ?? const EdgeInsets.all(AppDimensions.marginSmall),
      child: child,
    );

    if (onTap != null) {
      return Semantics(
        label: semanticLabel,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(context),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            child: cardContent,
          ),
        ),
      );
    }

    return Semantics(
      label: semanticLabel,
      child: cardContent,
    );
  }

  void _handleTap(BuildContext context) {
    debugPrint('🔍 DEBUG: AccessibleCard._handleTap() called with semanticLabel: $semanticLabel');
    if (onTap != null) {
      // Provide haptic feedback
      HapticFeedback.lightImpact();
      
      // Add voice feedback
      if (announceOnTap && semanticLabel != null) {
        final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
        ttsProvider.announceButtonPress(semanticLabel!);
      }
      
      debugPrint('🔍 DEBUG: AccessibleCard calling onTap callback');
      onTap!();
      debugPrint('🔍 DEBUG: AccessibleCard onTap callback completed');
    }
  }
}

/// Status card for displaying connection/sensor status
class AccessibleStatusCard extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;
  final Color statusColor;
  final String? semanticLabel;
  final VoidCallback? onTap;

  const AccessibleStatusCard({
    super.key,
    required this.title,
    required this.status,
    required this.icon,
    required this.statusColor,
    this.semanticLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleCard(
      onTap: onTap,
      semanticLabel: semanticLabel ?? '$title: $status',
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppDimensions.marginXSmall),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: AppDimensions.iconSmall,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}

/// Information card for displaying sensor data
class AccessibleInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color? valueColor;
  final String? semanticLabel;

  const AccessibleInfoCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.valueColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleCard(
      semanticLabel: semanticLabel ?? '$label: $value ${unit ?? ''}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: AppColors.primary,
              size: AppDimensions.iconMedium,
            ),
            const SizedBox(height: AppDimensions.marginSmall),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimensions.marginXSmall),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.primary,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: AppDimensions.marginXSmall),
                Text(
                  unit!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
