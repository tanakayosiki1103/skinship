//
//  SettingsView.swift
//  Skinship
//
//  Created by 田中　よしき on 2025/08/04.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Form {
            Toggle("音声読み上げを有効にする", isOn: $settings.isVoiceEnabled)
        }
        Text("""
                ※ 音声を男性に切り替えるには
                iPhoneの「設定」→「アクセシビリティ」→「スピーチ」→「声」から
                「日本語」の「Otoya」を選択してください。
                """)
        .font(.footnote)
        .foregroundColor(.gray)
        .multilineTextAlignment(.center)
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("設定")
    }
}


#Preview {
    SettingsView()
}
