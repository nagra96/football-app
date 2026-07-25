import 'package:flutter/services.dart';

/// Bridge to native app-blocking.
///
/// On iOS this is backed by the Screen Time stack (FamilyControls +
/// ManagedSettings) implemented in ios/Runner/AppDelegate.swift. The user
/// grants Screen Time access once, picks which apps to shield with the system
/// FamilyActivityPicker (the selection is opaque tokens — the app never learns
/// which apps were chosen), and the shield is raised for the length of each
/// focus session.
///
/// Distribution builds additionally need Apple's approval of the
/// com.apple.developer.family-controls entitlement for this bundle ID; the
/// development entitlement in Runner.entitlements works on any dev build. On
/// platforms without the channel (web, tests, Android for now) every call
/// degrades gracefully and Site Buddy runs in guard reminder mode.
class AppBlockService {
  static const _channel = MethodChannel('sitebuddy/appblock');

  static Future<bool> _boolCall(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> _voidCall(String method, [dynamic args]) async {
    try {
      await _channel.invokeMethod<void>(method, args);
    } on PlatformException {
      // Blocking not available on this build — guards handle it in-app.
    } on MissingPluginException {
      // Web / tests.
    }
  }

  /// Whether this build can raise a real app shield.
  static Future<bool> isBlockingAvailable() => _boolCall('isBlockingAvailable');

  /// Whether the user has granted Screen Time access.
  static Future<bool> isAuthorized() => _boolCall('isAuthorized');

  /// Prompts the system Screen Time authorization dialog.
  static Future<bool> requestAuthorization() => _boolCall('requestAuthorization');

  /// Opens the system FamilyActivityPicker; returns true if a selection was
  /// saved.
  static Future<bool> pickApps() => _boolCall('pickApps');

  /// Whether the user has picked at least one app/category to shield.
  static Future<bool> hasSelection() => _boolCall('hasSelection');

  /// Raise the shield for a session. [apps] is the display list used by the
  /// in-app guards; the native side shields its own token selection.
  static Future<void> startShield(List<String> apps) =>
      _voidCall('startShield', {'apps': apps});

  static Future<void> stopShield() => _voidCall('stopShield');
}
