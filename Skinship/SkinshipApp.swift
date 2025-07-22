//
//  SkinshipApp.swift
//  Skinship
//
//  Created by 田中　よしき on 2025/07/20.
//

import SwiftUI

@main
struct SkinshipApp: App {
  
        @StateObject private var settings = UserSettings()
        
        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(settings)  // 必要に応じて環境オブジェクトで渡す
            }
        }
    }

