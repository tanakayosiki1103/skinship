import SwiftUI

struct FeelingSelectionView: View {
    @EnvironmentObject var settings: UserSettings
//    @AppStorage("isVoiceOn") private var isVoiceOn: Bool = true
    @State private var showGraph = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List(HugFeeling.allCases, id: \.self) { feeling in
                    NavigationLink(destination: HugFeelingView(feeling: feeling).environmentObject(settings)) {
                        Text(feeling.rawValue)
                            .padding()
                    }
                }
                
//                Button("音声設定") {
//                    isVoiceOn.toggle()
//                }
//                .buttonStyle(.bordered)
                
                NavigationLink(destination: SettingsView().environmentObject(settings)) {
                    Text("音声設定")
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            .padding(.bottom, 4)

                
                Button("トレンド") {
                    showGraph = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding()
                .navigationDestination(isPresented: $showGraph) {
                    SimpleGraphView()
                }
                
                Spacer()
                
//                Text("""
//                ※ 音声を男性に切り替えるには
//                iPhoneの「設定」→「アクセシビリティ」→「スピーチ」→「声」から
//                「日本語」の「Otoya」を選択してください。
//                """)
//                .font(.footnote)
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//                .padding()
//                .background(Color(UIColor.systemGroupedBackground))
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("今の気分を選んでね")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        isVoiceOn.toggle()
//                    }) {
//                        Image(systemName: isVoiceOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
//                            .foregroundColor(.blue)
                    }
                }
            }

        }
    

