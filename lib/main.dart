import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/constants/app_constants.dart';

/// Main entry point for the Cane AID application
/// Initializes necessary services and starts the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Set preferred orientations (portrait only for accessibility)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize app services (will be implemented later)
  // await _initializeServices();

  runApp(const CaneAidApp());
}

/// Initialize app services and dependencies
/// This will be expanded as we add more services
Future<void> _initializeServices() async {
  try {
    // Initialize dependency injection
    // await setupDependencyInjection();

    // Initialize local storage boxes
    // await _initializeStorageBoxes();

    // Initialize logging
    // await _initializeLogging();

    debugPrint('${AppConstants.appName} services initialized successfully');
  } catch (e) {
    debugPrint('Error initializing services: $e');
  }
}

/// Initialize Hive storage boxes
Future<void> _initializeStorageBoxes() async {
  // Settings box
  await Hive.openBox('settings');
  
  // Color history box
  await Hive.openBox('colorHistory');
  
  // Location history box
  await Hive.openBox('locationHistory');
  
  // App logs box
  await Hive.openBox('appLogs');
}
