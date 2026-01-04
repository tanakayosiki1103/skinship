//
//  SettingsView 2.swift
//  Skinship
//
//  Created by 田中　よしき on 2025/12/21.
//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("音声ON/OFF", isOn: $settings.isVoiceEnabled)
                    
                    Picker("性格選択", selection: $settings.selectedPersonality) {
                        Text("やさしい").tag(Personality.cheerful)
                        Text("明るい").tag(Personality.calm)
                        Text("クール").tag(Personality.thoughtful)
                    }
                    .pickerStyle(.segmented)
                    
                    Button("テスト再生") {
                        if settings.isVoiceEnabled {
                            settings.testSpeak()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                } header: {
                    Text("音声設定")
                }
                
                Section {
                    Text("説明文")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("設定")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserSettings())
    }
}
