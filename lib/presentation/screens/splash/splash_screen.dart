import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../providers/tts_provider.dart';

/// Splash screen with voice introduction for accessibility
/// Shows app logo, name, and provides audio feedback
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _textAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Logo animations
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Text fade animation
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeIn,
    ));
  }

  void _startSplashSequence() {
    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Start logo animation
    _logoAnimationController.forward();

    // Start text animation after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _textAnimationController.forward();
    });

    // Announce app start after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceAppStart();
    });

    // Navigate to next screen after splash duration
    Future.delayed(
      const Duration(milliseconds: AppConstants.splashScreenDurationMs),
      () {
        if (mounted) {
          _navigateToNextScreen();
        }
      },
    );
  }

  Future<void> _announceAppStart() async {
    try {
      final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
      await ttsProvider.announceScreenEntry('${AppConstants.appName} app starting');
    } catch (e) {
      debugPrint('TTS announcement error: $e');
    }
  }

  void _navigateToNextScreen() {
    // TODO: Check if first launch or permissions needed
    // For now, go to home screen
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Semantics(
          label: 'Cane AID app is starting',
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo with Animation
                AnimatedBuilder(
                  animation: _logoAnimationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusXLarge,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusXLarge,
                            ),
                            child: Image.asset(
                              'assets/images/Cane Aid Logo - Soft Colors.png',
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              semanticLabel: 'Cane AID logo',
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to icon if image fails to load
                                return const Icon(
                                  Icons.accessibility_new,
                                  size: 80,
                                  color: AppColors.primary,
                                  semanticLabel: 'Cane AID accessibility logo',
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppDimensions.marginXLarge),

                // App Name with Animation
                AnimatedBuilder(
                  animation: _textAnimationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            AppConstants.appName,
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.textLight,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                            semanticsLabel: 'Cane AID',
                          ),
                          const SizedBox(height: AppDimensions.marginSmall),
                          Text(
                            'Assistive Technology for the Visually Impaired',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textLight.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                            semanticsLabel: 'Assistive Technology for the Visually Impaired',
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppDimensions.marginXLarge * 2),

                // Loading Indicator
                AnimatedBuilder(
                  animation: _textAnimationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textFadeAnimation,
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppDimensions.marginMedium),

                // Loading Text
                AnimatedBuilder(
                  animation: _textAnimationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Text(
                        'Initializing accessibility features...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textLight.withOpacity(0.8),
                        ),
                        semanticsLabel: 'Initializing accessibility features',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
