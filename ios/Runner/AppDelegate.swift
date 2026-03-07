import Flutter
import UIKit
import WidgetKit

// ── Feature 03: App Group ID (must match NeuroLoadWidget.swift) ───────────────
private let kAppGroupID = "group.com.neuroload.app"

// ── Feature 03: UserDefaults keys ────────────────────────────────────────────
private enum WidgetKey {
    static let sessionActive       = "session_active"
    static let elapsedSeconds      = "elapsed_seconds"
    static let category            = "category"
    static let subCategory         = "sub_category"
    static let lapCount            = "lap_count"
    static let lastSessionMinutes  = "last_session_minutes"
    static let lastSessionCategory = "last_session_category"
}

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // ── Feature 03: Widget MethodChannel ─────────────────────────────────
        if let controller = window?.rootViewController as? FlutterViewController {
            let widgetChannel = FlutterMethodChannel(
                name: "neuroload/widget",
                binaryMessenger: controller.binaryMessenger
            )

            widgetChannel.setMethodCallHandler { [weak self] call, result in
                guard let self = self else { return }
                switch call.method {

                case "updateWidget":
                    guard let args = call.arguments as? [String: Any] else {
                        result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
                        return
                    }
                    self.writeWidgetDefaults(
                        isActive:       args["isActive"]            as? Bool   ?? false,
                        elapsedSeconds: args["elapsedSeconds"]      as? Int    ?? 0,
                        category:       args["category"]            as? String ?? "",
                        subCategory:    args["subCategory"]         as? String ?? "",
                        lapCount:       args["lapCount"]            as? Int    ?? 0,
                        lastMins:       args["lastSessionMinutes"]  as? Int,
                        lastCat:        args["lastSessionCategory"] as? String
                    )
                    result(nil)

                case "clearWidget":
                    guard let args = call.arguments as? [String: Any] else {
                        self.writeWidgetDefaults(
                            isActive: false, elapsedSeconds: 0,
                            category: "", subCategory: "", lapCount: 0,
                            lastMins: nil, lastCat: nil
                        )
                        result(nil)
                        return
                    }
                    self.writeWidgetDefaults(
                        isActive:       false,
                        elapsedSeconds: 0,
                        category:       "",
                        subCategory:    "",
                        lapCount:       0,
                        lastMins:       args["lastSessionMinutes"]  as? Int,
                        lastCat:        args["lastSessionCategory"] as? String
                    )
                    result(nil)

                default:
                    result(FlutterMethodNotImplemented)
                }
            }

            // ── Feature 01: Live Activity MethodChannel ───────────────────────
            // The channel is registered here; actual ActivityKit calls are
            // handled in LiveActivityHandler.swift (create when adding the
            // Widget Extension target in Xcode).
            let liveActivityChannel = FlutterMethodChannel(
                name: "neuroload/live_activity",
                binaryMessenger: controller.binaryMessenger
            )
            liveActivityChannel.setMethodCallHandler { call, result in
                // Stub — replace with real ActivityKit calls when the
                // NeuroLoadLiveActivity extension target is added in Xcode.
                switch call.method {
                case "startActivity", "updateActivity", "endActivity":
                    result(nil) // no-op until extension is created
                case "areActivitiesEnabled":
                    result(false)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // ── Feature 01/03: Deep-link URL scheme handler ───────────────────────────
    //
    // Handles neuroload:// URLs from:
    //   - iOS widget "Start Session" button → neuroload://setup
    //   - iOS widget / Live Activity "Distracted" button → neuroload://distracted
    //
    // GoRouter on the Flutter side already has routes for /setup and /distracted.

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Hand the URL to Flutter's go_router deep-link handler.
        // FlutterAppDelegate passes it through the plugin registration chain
        // which includes go_router's native implementation.
        return super.application(app, open: url, options: options)
    }

    // ── Helper: write state to App Group UserDefaults + reload WidgetKit ──────

    private func writeWidgetDefaults(
        isActive: Bool,
        elapsedSeconds: Int,
        category: String,
        subCategory: String,
        lapCount: Int,
        lastMins: Int?,
        lastCat: String?
    ) {
        guard let ud = UserDefaults(suiteName: kAppGroupID) else { return }

        ud.set(isActive,       forKey: WidgetKey.sessionActive)
        ud.set(elapsedSeconds, forKey: WidgetKey.elapsedSeconds)
        ud.set(category,       forKey: WidgetKey.category)
        ud.set(subCategory,    forKey: WidgetKey.subCategory)
        ud.set(lapCount,       forKey: WidgetKey.lapCount)
        if let mins = lastMins { ud.set(mins, forKey: WidgetKey.lastSessionMinutes) }
        if let cat  = lastCat  { ud.set(cat,  forKey: WidgetKey.lastSessionCategory) }
        ud.synchronize()

        // Tell WidgetKit to reload the timeline so the widget updates
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
