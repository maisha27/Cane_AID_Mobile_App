import 'package:flutter/material.dart';
import 'app_routes.dart';

// Import screens
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/websocket/websocket_test_screen.dart';
import '../../presentation/screens/websocket/websocket_connection_screen.dart';
// Disabled: import '../../presentation/screens/color_detection/color_detection_screen.dart';
import '../../presentation/screens/distance/distance_detection_screen.dart';
import '../../presentation/screens/location/location_screen.dart';
// import '../../presentation/screens/onboarding/welcome_screen.dart';
// import '../../presentation/screens/onboarding/permissions_screen.dart';
// import '../../presentation/screens/onboarding/setup_screen.dart';

/// Route generator for the Cane AID application
/// Handles navigation and route management with accessibility support
class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _createRoute(
          const SplashScreen(),
          settings,
        );

      case AppRoutes.welcome:
        return _createRoute(
          // WelcomeScreen(), // Will be created next
          _placeholderScreen('Welcome Screen'),
          settings,
        );

      case AppRoutes.permissions:
        return _createRoute(
          // PermissionsScreen(), // Will be created next
          _placeholderScreen('Permissions Screen'),
          settings,
        );

      case AppRoutes.setup:
        return _createRoute(
          // SetupScreen(), // Will be created next
          _placeholderScreen('Setup Screen'),
          settings,
        );

      case AppRoutes.home:
        return _createRoute(
          const HomeScreen(),
          settings,
        );

      case AppRoutes.colorDetection:
        // DISABLED: Color detection now handled in-place on home screen
        debugPrint('⚠️ WARNING: Old colorDetection route called! This should not happen.');
        return _createRoute(
          _placeholderScreen('Color Detection - Use Home Screen Animation'),
          settings,
        );

      case AppRoutes.distanceDetection:
        return _createRoute(
          const DistanceDetectionScreen(),
          settings,
        );

      case AppRoutes.location:
        return _createRoute(
          const LocationScreen(),
          settings,
        );

      case AppRoutes.websocket:
        return _createRoute(
          const WebSocketConnectionScreen(),
          settings,
        );

      case AppRoutes.websocketTest:
        return _createRoute(
          const WebSocketTestScreen(),
          settings,
        );

      case AppRoutes.help:
        return _createRoute(
          // HelpScreen(), // Will be created next
          _placeholderScreen('Help Screen'),
          settings,
        );

      case AppRoutes.tutorial:
        return _createRoute(
          // TutorialScreen(), // Will be created next
          _placeholderScreen('Tutorial Screen'),
          settings,
        );

      default:
        return _createRoute(
          _errorScreen(settings.name ?? 'Unknown'),
          settings,
        );
    }
  }

  /// Creates a route with proper accessibility semantics
  static Route<dynamic> _createRoute(Widget screen, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide transition for better accessibility
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Placeholder screen for development
  static Widget _placeholderScreen(String screenName) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              screenName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This screen is under development',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// Error screen for unknown routes
  static Widget _errorScreen(String routeName) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Route "$routeName" does not exist',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate back to home or previous screen
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
