import SwiftUI

struct UserListView: View {
    @EnvironmentObject var settings: UserSettings
    @Environment(\.dismiss) private var dismiss
    
    // ✅ MainView から渡す
    @Binding var isEditing: Bool
    
    @State private var showDeleteConfirm = false
    @State private var pendingDeleteOffsets: IndexSet? = nil
    
    var body: some View {
        ZStack {
            NeoBackground()
                .allowsHitTesting(false)
            
            VStack(spacing: 12) {
                
                // タイトルカード
                VStack(spacing: 6) {
                    Text(NSLocalizedString("user_list_title", comment: "User list title"))
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(NSLocalizedString("user_list_subtitle", comment: "User list subtitle"))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.70))
                }
                .padding(14)
                .glassCard(0.14)
                .padding(.top, 12)
                
                if settings.userList.isEmpty {
                    emptyState
                } else {
                    listContent
                }
                
                Spacer(minLength: 8)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: 560)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black.opacity(0.35), for: .navigationBar)
        
        // ✅ 編集ボタン復活（ここが今回の肝）
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .black))
                }
                .foregroundStyle(.white.opacity(0.9))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isEditing.toggle()
                    }
                } label: {
                    Text(isEditing
                         ? NSLocalizedString("user_list_done", comment: "Done")
                         : NSLocalizedString("user_list_edit", comment: "Edit"))
                    .font(.system(size: 14, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white.opacity(0.9))
                .disabled(settings.userList.isEmpty)
                .opacity(settings.userList.isEmpty ? 0.35 : 1.0)
            }
        }
        
        .confirmationDialog(
            NSLocalizedString("user_list_delete_confirm_title", comment: "Delete confirm title"),
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("user_list_delete", comment: "Delete"), role: .destructive) {
                guard let offsets = pendingDeleteOffsets else { return }
                delete(at: offsets)
                pendingDeleteOffsets = nil
            }
            Button(NSLocalizedString("user_list_cancel", comment: "Cancel"), role: .cancel) {
                pendingDeleteOffsets = nil
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white.opacity(0.85))
            
            Text(NSLocalizedString("user_list_empty_title", comment: "Empty state title"))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            
            Text(NSLocalizedString("user_list_empty_subtitle", comment: "Empty state subtitle"))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.65))
        }
        .padding(18)
        .glassCard(0.12)
        .padding(.top, 6)
    }
    
    private var listContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(Array(settings.userList.enumerated()), id: \.offset) { index, user in
                    
                    // ✅ 編集中は「選択で閉じる」を無効にして、削除モードに寄せる
                    Button {
                        if isEditing {
                            pendingDeleteOffsets = IndexSet(integer: index)
                            showDeleteConfirm = true
                            return
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        settings.name = user
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.10))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white.opacity(0.9))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                )
                            
                            // ✅ 名前 + 性別表示
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user)
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                                
                                Text(genderLabel(for: user))
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.65))
                            }
                            
                            Spacer()
                            
                            if isEditing {
                                Image(systemName: "trash")
                                    .font(.system(size: 15, weight: .black))
                                    .foregroundColor(.white.opacity(0.75))
                            } else if settings.name == user {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white.opacity(0.95))
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(.white.opacity(0.55))
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 14)
                        .glassCard(0.12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.98, yOffset: 1))
                    
                    // ✅ 編集中はロングタップ不要でもOKだけど、残したいならここも残せる
                    .contextMenu {
                        Button(role: .destructive) {
                            pendingDeleteOffsets = IndexSet(integer: index)
                            showDeleteConfirm = true
                        } label: {
                            Label(
                                NSLocalizedString("user_list_delete", comment: "Delete"),
                                systemImage: "trash"
                            )
                        }
                    }
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 10)
        }
    }
    
    private func genderLabel(for user: String) -> String {
        let g = settings.userGenderMap[user] ?? ""
        switch g {
        case "female":
            return NSLocalizedString("gender_female", comment: "Female short label")
        case "male":
            return NSLocalizedString("gender_male", comment: "Male short label")
        default:
            return NSLocalizedString("gender_unknown_short", comment: "Unknown short label")
        }
    }
    
    private func delete(at offsets: IndexSet) {
        let deletingNames = offsets.map { settings.userList[$0] }
        
        settings.userList.remove(atOffsets: offsets)
        for name in deletingNames {
            settings.userGenderMap.removeValue(forKey: name)
        }
        
        if deletingNames.contains(settings.name) {
            settings.clearPartner()
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}


#Preview("UserListView - en") {
    NavigationStack {
        UserListView(isEditing: .constant(false))
            .environmentObject(UserSettings())
    }
    .environment(\.locale, Locale(identifier: "en"))
}
