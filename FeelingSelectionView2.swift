import SwiftUI

struct FeelingSelectionView2: View {
    @EnvironmentObject var settings: UserSettings
    @State private var selectedPart: HugPart? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ローカライズ対応済みタイトル
                    Text(NSLocalizedString("select_hug_part", comment: "Prompt for selecting hug part"))
                        .font(.title3)
                        .padding(.top, 20)
                        .minimumScaleFactor(0.8)
                    
                    // HugPart 選択ボタン
                    ForEach(HugPart.allCases, id: \.self) { part in
                        NavigationLink(destination: HugFeelingView2(part: part).environmentObject(settings)) {
                            Text(part.localizedName)
 // HugPart側も別途ローカライズ可
                                .font(.title2)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.pink.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: Binding(
                    get: { selectedPart != nil && settings.selectedFeeling != nil },
                    set: { _ in /* no-op */ }
                )) {
                    if let part = selectedPart {
                        HugFeelingView2(part: part)
                            .environmentObject(settings)
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }
}

#Preview {
    FeelingSelectionView2()
        .environmentObject(UserSettings())
}
