import SwiftUI

struct FeelingSelectionView: View {
    @ObservedObject var settings: UserSettings
    
    var body: some View {
        List(HugFeeling.allCases, id: \.self) { feeling in
            NavigationLink {
                HugFeelingView(feeling: feeling, settings: settings)
            } label: {
                Text(feeling.rawValue)
                    .padding()
            }
        }
        .navigationTitle("今、どんな気分？")
    }
}

#Preview {
    FeelingSelectionView(settings: UserSettings())
}
