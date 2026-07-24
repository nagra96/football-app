import 'package:flutter/services.dart';

/// Bridge to native app-blocking.
///
/// On iOS, true app blocking uses the Screen Time APIs (FamilyControls +
/// ManagedSettings), which require the com.apple.developer.family-controls
/// entitlement granted by Apple. The native side of this channel lives in
/// ios/Runner/AppDelegate.swift; until the entitlement build is wired up it
/// reports blocking as unavailable and Site Buddy runs in "guard reminder"
/// mode: mini buddies watch the session and call out when you leave the app.
class AppBlockService {
  static const _channel = MethodChannel('sitebuddy/appblock');

  static Future<bool> isBlockingAvailable() async {
    try {
      final available = await _channel.invokeMethod<bool>('isBlockingAvailable');
      return available ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Ask the native side to shield the given apps for the session.
  /// No-op while blocking is unavailable.
  static Future<void> startShield(List<String> apps) async {
    try {
      await _channel.invokeMethod<void>('startShield', {'apps': apps});
    } on PlatformException {
      // Blocking not available on this build — guards handle it in-app.
    } on MissingPluginException {
      // Web / tests.
    }
  }

  static Future<void> stopShield() async {
    try {
      await _channel.invokeMethod<void>('stopShield');
    } on PlatformException {
      // ignore
    } on MissingPluginException {
      // ignore
    }
  }
}
