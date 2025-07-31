//
//  LumaApp.swift
//  Luma
//
//  Created by Thilo Wilts on 23.07.25.
//

import SwiftUI
import Foundation

/// Entry point for the Luma application.
///
/// The ``LumaApp`` bootstraps the SwiftUI hierarchy and injects
/// the ``StatsStore`` that tracks usage metrics.
@main
struct LumaApp: App {
    /// Shared statistics store available throughout the app.
    @StateObject private var stats = StatsStore()
    @StateObject private var sessionStore = SessionStore()

    /// Top-level scene hosting the content view.
    var body: some Scene {
        WindowGroup {
            // Inject the stats store into the environment so all
            // child views can record analytics.
            ContentView()
                .environmentObject(stats)
                .environmentObject(sessionStore)
                .task {
                    await sessionStore.ensureSession()
                }
        }
    }
}
