import FamilyControls
import Flutter
import ManagedSettings
import SwiftUI
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

    // App-blocking bridge backed by the Screen Time stack (FamilyControls +
    // ManagedSettings). Requires the com.apple.developer.family-controls
    // entitlement: enabled for development via Runner.entitlements, and for
    // App Store distribution once Apple approves the entitlement request for
    // this bundle ID.
    let appBlockChannel = FlutterMethodChannel(
      name: "sitebuddy/appblock",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    appBlockChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "isBlockingAvailable":
        result(true)
      case "isAuthorized":
        result(AppBlocker.shared.isAuthorized)
      case "requestAuthorization":
        Task { @MainActor in
          result(await AppBlocker.shared.requestAuthorization())
        }
      case "pickApps":
        self?.presentAppPicker(result: result)
      case "hasSelection":
        result(AppBlocker.shared.hasSelection)
      case "startShield":
        AppBlocker.shared.startShield()
        result(nil)
      case "stopShield":
        AppBlocker.shared.stopShield()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func presentAppPicker(result: @escaping FlutterResult) {
    guard
      let root = UIApplication.shared.connectedScenes
        .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
        .first?.rootViewController
    else {
      result(false)
      return
    }
    var host: UIHostingController<AppPickerView>?
    let picker = AppPickerView(
      selection: AppBlocker.shared.savedSelection,
      onDone: { selection in
        if let selection {
          AppBlocker.shared.savedSelection = selection
        }
        host?.dismiss(animated: true)
        result(selection != nil)
      }
    )
    let controller = UIHostingController(rootView: picker)
    host = controller
    root.present(controller, animated: true)
  }
}

/// Wraps the system FamilyActivityPicker so the user chooses which apps the
/// crew shields during focus sessions. Selections are opaque tokens — the app
/// never learns which apps were picked.
struct AppPickerView: View {
  @State var selection: FamilyActivitySelection
  let onDone: (FamilyActivitySelection?) -> Void

  var body: some View {
    NavigationView {
      FamilyActivityPicker(selection: $selection)
        .navigationTitle("Apps to shield")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { onDone(nil) }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button("Done") { onDone(selection) }
          }
        }
    }
  }
}

/// Owns Screen Time authorization, the persisted app selection, and the
/// ManagedSettings shield that blocks the selected apps during a session.
final class AppBlocker {
  static let shared = AppBlocker()
  private init() {}

  private let store = ManagedSettingsStore()
  private let selectionKey = "sitebuddy.familyActivitySelection"

  var isAuthorized: Bool {
    AuthorizationCenter.shared.authorizationStatus == .approved
  }

  @MainActor
  func requestAuthorization() async -> Bool {
    do {
      try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
      return true
    } catch {
      return false
    }
  }

  var savedSelection: FamilyActivitySelection {
    get {
      guard
        let data = UserDefaults.standard.data(forKey: selectionKey),
        let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
      else {
        return FamilyActivitySelection()
      }
      return selection
    }
    set {
      if let data = try? JSONEncoder().encode(newValue) {
        UserDefaults.standard.set(data, forKey: selectionKey)
      }
    }
  }

  var hasSelection: Bool {
    let selection = savedSelection
    return !selection.applicationTokens.isEmpty
      || !selection.categoryTokens.isEmpty
      || !selection.webDomainTokens.isEmpty
  }

  func startShield() {
    guard isAuthorized else { return }
    let selection = savedSelection
    store.shield.applications =
      selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
    store.shield.applicationCategories =
      selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
    store.shield.webDomains =
      selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
  }

  func stopShield() {
    store.shield.applications = nil
    store.shield.applicationCategories = nil
    store.shield.webDomains = nil
  }
}
