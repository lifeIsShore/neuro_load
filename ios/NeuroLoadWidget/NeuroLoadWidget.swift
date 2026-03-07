// NeuroLoadWidget.swift
// Feature 03: iOS home screen widget using WidgetKit.
//
// SETUP REQUIRED IN XCODE:
//   1. File → New → Target → Widget Extension
//   2. Name it "NeuroLoadWidget", disable "Include Configuration Intent"
//   3. Replace the generated Swift file with this file
//   4. Add the App Group "group.com.neuroload.app" to both:
//        Runner target  → Signing & Capabilities → App Groups
//        NeuroLoadWidget target → Signing & Capabilities → App Groups
//   5. In Runner's Info.plist add:
//        <key>NSSupportsLiveActivities</key><true/>      (for Feature 01)
//        <key>NSSupportsLiveActivitiesFrequentUpdates</key><true/>
//   6. In NeuroLoadWidget/Info.plist the NSExtension entry is auto-generated
//      by Xcode when you create the target.
//
// Flutter writes to UserDefaults(suiteName: "group.com.neuroload.app") via
// the MethodChannel in AppDelegate.swift, then calls
// WidgetCenter.shared.reloadAllTimelines() to trigger a provider refresh.
//
// The widget reads the same UserDefaults on its timeline provider pass.

import WidgetKit
import SwiftUI

// ── App Group ID ──────────────────────────────────────────────────────────────

private let appGroupID = "group.com.neuroload.app"

// ── UserDefaults keys (must match AppDelegate.swift) ─────────────────────────

private enum WidgetKey {
    static let sessionActive        = "session_active"
    static let elapsedSeconds       = "elapsed_seconds"
    static let category             = "category"
    static let subCategory          = "sub_category"
    static let lapCount             = "lap_count"
    static let lastSessionMinutes   = "last_session_minutes"
    static let lastSessionCategory  = "last_session_category"
}

// ── Timeline Entry ────────────────────────────────────────────────────────────

struct NeuroLoadEntry: TimelineEntry {
    let date: Date
    let isActive: Bool
    let elapsedSeconds: Int
    let category: String
    let subCategory: String
    let lapCount: Int
    let lastSessionMinutes: Int?
    let lastSessionCategory: String?
}

// ── Timeline Provider ─────────────────────────────────────────────────────────

struct NeuroLoadProvider: TimelineProvider {

    func placeholder(in context: Context) -> NeuroLoadEntry {
        NeuroLoadEntry(
            date: Date(), isActive: false,
            elapsedSeconds: 0, category: "", subCategory: "",
            lapCount: 0, lastSessionMinutes: nil, lastSessionCategory: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NeuroLoadEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NeuroLoadEntry>) -> Void) {
        let entry = currentEntry()
        // When active: refresh every minute. Idle: every 30 minutes.
        let interval: TimeInterval = entry.isActive ? 60 : 1800
        let nextUpdate = Date().addingTimeInterval(interval)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    // ── Read from App Group shared defaults ───────────────────────────────────

    private func currentEntry() -> NeuroLoadEntry {
        let ud = UserDefaults(suiteName: appGroupID)
        let isActive  = ud?.bool(forKey: WidgetKey.sessionActive)       ?? false
        let elapsed   = ud?.integer(forKey: WidgetKey.elapsedSeconds)   ?? 0
        let category  = ud?.string(forKey: WidgetKey.category)          ?? ""
        let subCat    = ud?.string(forKey: WidgetKey.subCategory)       ?? ""
        let lapCount  = ud?.integer(forKey: WidgetKey.lapCount)         ?? 0
        let lastMins  = ud?.object(forKey: WidgetKey.lastSessionMinutes) as? Int
        let lastCat   = ud?.string(forKey: WidgetKey.lastSessionCategory)

        return NeuroLoadEntry(
            date: Date(),
            isActive: isActive,
            elapsedSeconds: elapsed,
            category: category,
            subCategory: subCat,
            lapCount: lapCount,
            lastSessionMinutes: lastMins,
            lastSessionCategory: lastCat
        )
    }
}

// ── Colour palette (Obsidian Noir) ────────────────────────────────────────────

private let bgColor      = Color(red: 0.039, green: 0.039, blue: 0.039) // #0A0A0A
private let surfaceColor = Color(red: 0.118, green: 0.118, blue: 0.118) // #1E1E1E
private let teal         = Color(red: 0.000, green: 0.710, blue: 0.647) // #00B5A5
private let textPrimary  = Color(red: 0.910, green: 0.910, blue: 0.910) // #E8E8E8
private let textGrey     = Color(red: 0.533, green: 0.533, blue: 0.533) // #888888
private let dimGrey      = Color(red: 0.314, green: 0.314, blue: 0.314) // #505050

// ── Widget Entry View ─────────────────────────────────────────────────────────

struct NeuroLoadWidgetEntryView: View {
    let entry: NeuroLoadEntry

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            if entry.isActive {
                ActiveView(entry: entry)
            } else {
                IdleView(entry: entry)
            }
        }
        .containerBackground(bgColor, for: .widget)
    }
}

// ── Active state ──────────────────────────────────────────────────────────────

private struct ActiveView: View {
    let entry: NeuroLoadEntry

    private var timeString: String {
        let h = entry.elapsedSeconds / 3600
        let m = (entry.elapsedSeconds % 3600) / 60
        let s = entry.elapsedSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Category label
            if !entry.category.isEmpty {
                Text(entry.category.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(teal)
            }

            // Sub-category
            if !entry.subCategory.isEmpty {
                Text(entry.subCategory)
                    .font(.system(size: 11))
                    .foregroundColor(textGrey)
            }

            // Large elapsed timer — the focal point
            Text(timeString)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(textPrimary)
                .minimumScaleFactor(0.7)

            Spacer()

            HStack {
                // Lap count
                if entry.lapCount > 0 {
                    Text("\(entry.lapCount) lap\(entry.lapCount != 1 ? "s" : "")")
                        .font(.system(size: 11))
                        .foregroundColor(textGrey)
                }
                Spacer()
                // Distracted button — small, bottom-right
                Link(destination: URL(string: "neuroload://distracted")!) {
                    Text("Distracted")
                        .font(.system(size: 11))
                        .foregroundColor(textGrey)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(surfaceColor)
                        .cornerRadius(6)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// ── Idle state ────────────────────────────────────────────────────────────────

private struct IdleView: View {
    let entry: NeuroLoadEntry

    private var subtitleText: String {
        if let mins = entry.lastSessionMinutes, let cat = entry.lastSessionCategory {
            return "Last · \(mins)min · \(cat)"
        } else if let mins = entry.lastSessionMinutes {
            return "Last session · \(mins)min"
        }
        return "Your first session is waiting."
    }

    var body: some View {
        VStack(alignment: .leading) {
            // App name
            Text("NEUROLOAD")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(teal)

            Spacer()

            // Start Session CTA
            Link(destination: URL(string: "neuroload://setup")!) {
                HStack {
                    Spacer()
                    Text("Start Session")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(bgColor)
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(teal)
                .cornerRadius(8)
            }

            Spacer().frame(height: 8)

            // Last session / intro line
            Text(subtitleText)
                .font(.system(size: 10))
                .foregroundColor(dimGrey)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// ── Widget Configuration ──────────────────────────────────────────────────────

struct NeuroLoadWidgetBundle: WidgetBundle {
    var body: some Widget {
        NeuroLoadWidgetConfig()
    }
}

struct NeuroLoadWidgetConfig: Widget {
    let kind: String = "NeuroLoadWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NeuroLoadProvider()) { entry in
            NeuroLoadWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NeuroLoad")
        .description("Your focus session at a glance.")
        .supportedFamilies([.systemMedium])
    }
}
