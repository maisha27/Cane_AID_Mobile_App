import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../presentation/providers/tts_provider.dart';
import '../presentation/providers/bluetooth_provider.dart';
import '../presentation/providers/websocket_provider.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import '../l10n/generated/app_localizations.dart';

// Import providers (will be created in next steps)
// import '../presentation/providers/language_provider.dart';
// import '../presentation/providers/accessibility_provider.dart';
// import '../presentation/providers/settings_provider.dart';

/// Main application widget for Cane AID
/// Configures app-wide settings including localization, theme, and routing
class CaneAidApp extends StatelessWidget {
  const CaneAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // TTS Provider for voice feedback
        ChangeNotifierProvider(
          create: (_) => TTSProvider()..initialize(),
        ),
        // Bluetooth Provider for ESP32 communication (legacy)
        ChangeNotifierProvider(
          create: (_) => BluetoothProvider()..initialize(),
        ),
        // WebSocket Provider for ESP32 communication via laptop bridge
        ChangeNotifierProvider(
          create: (_) => WebSocketProvider()..initialize(),
        ),
        // Will add more providers here as we create them
        // ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
        // ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer3<TTSProvider, BluetoothProvider, WebSocketProvider>(
        builder: (context, ttsProvider, bluetoothProvider, webSocketProvider, child) {
          return MaterialApp(
            // App Configuration
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            highContrastTheme: AppTheme.highContrastTheme,
            themeMode: ThemeMode.system, // Will be controlled by provider

            // Localization Configuration
            locale: const Locale('en'),
            supportedLocales: const [Locale('en')],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Routing Configuration
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,

            // Accessibility Configuration
            builder: (context, child) {
              return _AccessibilityWrapper(child: child!);
            },
          );
        },
      ),
    );
  }
}

/// Wrapper widget to apply accessibility configurations
class _AccessibilityWrapper extends StatelessWidget {
  final Widget child;

  const _AccessibilityWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // Ensure text scaling is accessible but not too large
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.5),
        ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        child: child,
      ),
    );
  }
}
