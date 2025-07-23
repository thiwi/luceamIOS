//
//  LumaApp.swift
//  Luma
//
//  Created by Thilo Wilts on 23.07.25.
//

import SwiftUI

@main
struct LumaApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView(showSplash: $showSplash)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showSplash = false
                        }
                    }
            } else {
                ContentView()
            }
        }
    }
}
