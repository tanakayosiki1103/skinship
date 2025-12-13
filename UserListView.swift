import SwiftUI

// gender の内部値 → 表示用文字列変換
extension String {
    func localizedDisplayName() -> String {
        let preferredLanguage = Locale.preferredLanguages.first ?? "ja"
        switch self {
        case "male":
            return preferredLanguage.hasPrefix("ja") ? "男性" : "male"
        case "female":
            return preferredLanguage.hasPrefix("ja") ? "女性" : "female"
        default:
            return self
        }
    }
}

struct UserListView: View {
    @EnvironmentObject var settings: UserSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            if settings.userList.isEmpty {
                Text("登録ユーザーはいません")
                    .foregroundColor(.gray)
            } else {
                ForEach(settings.userList, id: \.id) { user in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.headline)
                            Text("(\(user.gender.localizedDisplayName()))")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        Spacer()
                        Button("選択") {
                            // ユーザー切り替え
                            settings.name = user.name
                            settings.selectedGender = user.gender // 内部値は male/female のまま
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .onDelete { indexSet in
                    settings.userList.remove(atOffsets: indexSet)
                    settings.saveUserList()
                }
            }
        }
        .navigationTitle(NSLocalizedString("user_list_title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton() // スワイプ削除を有効化
        }
    }
}

#Preview {
    UserListView().environmentObject(UserSettings())
}
