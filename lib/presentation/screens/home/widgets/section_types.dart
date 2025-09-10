/// Section types and states for the single-page home screen
enum SectionType {
  colorDetection,
  obstacleDetection,
  location,
  connection,
}

enum SectionState {
  collapsed,
  expanding,
  expanded,
  collapsing,
}

/// Extension methods for SectionType
extension SectionTypeExtension on SectionType {
  String get title {
    switch (this) {
      case SectionType.colorDetection:
        return 'Color Detection';
      case SectionType.obstacleDetection:
        return 'Obstacle Detection';
      case SectionType.location:
        return 'Location Services';
      case SectionType.connection:
        return 'Connection to Cane_AID';
    }
  }
  
  String get subtitle {
    switch (this) {
      case SectionType.colorDetection:
        return 'Real-time color identification using camera';
      case SectionType.obstacleDetection:
        return 'Real-time obstacle detection using sensors';
      case SectionType.location:
        return 'Share location with caretakers';
      case SectionType.connection:
        return 'Connect to your Cane AID device';
    }
  }
  
  String get semanticLabel {
    switch (this) {
      case SectionType.colorDetection:
        return 'Color Detection feature. Real-time color identification using camera.';
      case SectionType.obstacleDetection:
        return 'Obstacle Detection feature. Real-time obstacle detection using sensors.';
      case SectionType.location:
        return 'Location Services feature. Share location with caretakers.';
      case SectionType.connection:
        return 'Connection to Cane AID feature. Connect to your Cane AID device.';
    }
  }
}
