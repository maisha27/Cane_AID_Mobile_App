import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/tts_provider.dart';

/// Accessible button widget with voice feedback and proper touch targets
/// Ensures minimum 48x48dp touch area and provides haptic feedback
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool isOutlined;
  final bool announceOnPress;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.width,
    this.height,
    this.isOutlined = false,
    this.announceOnPress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: SizedBox(
        width: width,
        height: height ?? AppDimensions.buttonHeight,
        child: isOutlined
            ? OutlinedButton(
                onPressed: () => _handlePress(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor ?? AppColors.primary,
                  padding: padding ?? 
                    const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall,
                    ),
                  minimumSize: const Size(
                    AppDimensions.buttonMinWidth,
                    AppDimensions.buttonHeight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                  ),
                  side: BorderSide(
                    color: foregroundColor ?? AppColors.primary,
                    width: 2,
                  ),
                ),
                child: child,
              )
            : ElevatedButton(
                onPressed: () => _handlePress(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor ?? AppColors.primary,
                  foregroundColor: foregroundColor ?? AppColors.textLight,
                  padding: padding ?? 
                    const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall,
                    ),
                  minimumSize: const Size(
                    AppDimensions.buttonMinWidth,
                    AppDimensions.buttonHeight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                  ),
                  elevation: 2,
                ),
                child: child,
              ),
      ),
    );
  }

  void _handlePress(BuildContext context) {
    if (onPressed != null) {
      // Provide haptic feedback
      HapticFeedback.lightImpact();
      
      // Add voice feedback
      if (announceOnPress) {
        _announceButtonPress(context);
      }
      
      onPressed!();
    }
  }

  void _announceButtonPress(BuildContext context) {
    if (semanticLabel != null) {
      final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
      ttsProvider.announceButtonPress(semanticLabel!);
    }
  }
}

/// Large accessible button for primary actions
class AccessiblePrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  const AccessiblePrimaryButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleButton(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      height: AppDimensions.buttonLargeHeight,
      backgroundColor: AppColors.primary,
      child: child,
    );
  }
}

/// Secondary accessible button for secondary actions
class AccessibleSecondaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  const AccessibleSecondaryButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleButton(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      backgroundColor: AppColors.secondary,
      isOutlined: true,
      child: child,
    );
  }
}

/// Icon button with accessibility support
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final Color? color;
  final double? size;
  final bool announceOnPress;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.color,
    this.size,
    this.announceOnPress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? tooltip,
      button: true,
      enabled: onPressed != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handlePress(context),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            width: AppDimensions.minTouchTarget,
            height: AppDimensions.minTouchTarget,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: color ?? AppColors.primary,
              size: size ?? AppDimensions.iconMedium,
              semanticLabel: semanticLabel ?? tooltip,
            ),
          ),
        ),
      ),
    );
  }

  void _handlePress(BuildContext context) {
    if (onPressed != null) {
      HapticFeedback.lightImpact();
      
      if (announceOnPress) {
        final label = semanticLabel ?? tooltip;
        if (label != null) {
          final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
          ttsProvider.announceButtonPress(label);
        }
      }
      
      onPressed!();
    }
  }
}
