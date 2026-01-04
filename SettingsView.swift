import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $settings.isVoiceEnabled) {
                    Text("voice_enable")
                }
                
                Picker(selection: $settings.selectedPersonality,
                       label: Text("personality_select")) {
                    Text("personality_gentle").tag(Personality.cheerful)
                    Text("personality_bright").tag(Personality.calm)
                    Text("personality_cool").tag(Personality.thoughtful)
                }
                       .pickerStyle(.segmented)
                HStack {
                    Spacer()
                    
                    Button {
                        settings.testSpeak()
                    } label: {
                        Text("voice_test")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .foregroundStyle(.white)
                            .frame(minWidth: 160)
                    }
                    .background(settings.isVoiceEnabled ? Color.green : Color.gray)
                    .clipShape(Capsule())
                    .shadow(
                        color: settings.isVoiceEnabled ? Color.green.opacity(0.35) : .clear,
                        radius: settings.isVoiceEnabled ? 8 : 0
                    )
                    .allowsHitTesting(settings.isVoiceEnabled)     // OFF時は押せない
                    .opacity(settings.isVoiceEnabled ? 1.0 : 0.7)  // OFF感を少し出す（任意）
                    
                    Spacer()
                }



            }


            
            // ✅ 長文は footer じゃなく「専用枠」にする（省略されない）
            Section {
                TextEditor(text: .constant(String(localized: "voice_description")))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(minHeight: 400)          // 好みで増やす
                    .scrollDisabled(true)           // 中でスクロールさせない（全文を伸ばして出す）
                    .disabled(true)                 // 編集できないように
                    .textSelection(.enabled)        // コピーできる
            }
        }
        .navigationTitle(Text("voice_settings"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
