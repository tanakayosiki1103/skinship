import SwiftUI

struct FeelingSelectionView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var showGraph = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // リスト部分
                    ForEach(HugFeeling.allCases, id: \.self) { feeling in
                        NavigationLink(destination: HugFeelingView(feeling: feeling).environmentObject(settings)) {
                            Text(NSLocalizedString(feeling.rawValue, comment: ""))
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .background(Color.white)
                                .border(Color.gray.opacity(0.3), width: 0.5)
                        }
                    }
                    
                    // ボタン部分
                    VStack(spacing: 10) {
                        NavigationLink(destination: SettingsView().environmentObject(settings)) {
                            Text(NSLocalizedString("voice_settings", comment: ""))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        
                        Button(NSLocalizedString("trend", comment: "")) {
                            showGraph = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .navigationDestination(isPresented: $showGraph) {
                            SimpleGraphView()
                        }
                        
                        NavigationLink(destination: NameInputView2().environmentObject(settings)) {
                            Text(NSLocalizedString("exciting_experience", comment: ""))
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        
                        Button(NSLocalizedString("gift_friend", comment: "")) {
                            if let url = URL(string: "https://apps.apple.com/jp/app/%E3%83%9E%E3%83%83%E3%83%81%E3%83%B3%E3%82%B0-%E3%83%95%E3%82%A3%E3%83%BC%E3%83%AA%E3%83%B3%E3%82%B0/id6748877770?action=gift") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.top, 20)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(Text(NSLocalizedString("select_feeling", comment: "")))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FeelingSelectionView()
        .environmentObject(UserSettings())
}
