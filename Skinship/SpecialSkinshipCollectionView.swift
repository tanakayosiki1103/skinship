import SwiftUI

struct SpecialSkinshipCollectionView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        List {
            if settings.specialLines.isEmpty {
                Text(NSLocalizedString("special_collection_empty", comment: "空"))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(settings.specialLines) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.text)
                            .lineLimit(2)
                        Text(item.createdAt, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        settings.speak(item.text)
                    }
                }
                .onDelete { offsets in
                    settings.deleteSpecialLines(at: offsets)
                }
            }
        }
        .navigationTitle(NSLocalizedString("special_collection_title", comment: "スペシャルスキンシップ集"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { EditButton() }
    }
}

#Preview {
    NavigationStack {
        SpecialSkinshipCollectionView()
            .environmentObject(UserSettings())
    }
}
