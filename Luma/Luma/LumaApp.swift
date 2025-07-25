//
//  LumaApp.swift
//  Luma
//
//  Created by Thilo Wilts on 23.07.25.
//

import SwiftUI

@main
struct LumaApp: App {
    @StateObject private var stats = StatsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(stats)
        }
        .supportedOrientations(.portrait)
    }
}
