import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Native app-blocking bridge. True app blocking on iOS uses the Screen
    // Time stack (FamilyControls + ManagedSettings + DeviceActivity), which
    // needs the com.apple.developer.family-controls entitlement approved by
    // Apple for this bundle ID. Until that build is wired up, this channel
    // reports blocking as unavailable and the Flutter side runs in guard
    // reminder mode. Swap the stubbed cases below for a ManagedSettingsStore
    // shield once the entitlement lands.
    let appBlockChannel = FlutterMethodChannel(
      name: "sitebuddy/appblock",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    appBlockChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "isBlockingAvailable":
        result(false)
      case "startShield", "stopShield":
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
