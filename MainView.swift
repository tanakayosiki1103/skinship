import SwiftUI

struct MainView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var gradientColors: [Color] = [Color.pink, Color.purple, Color.orange]
    @State private var navigateToFeeling = false
    @State private var animateButton = false
    @State private var isPressed = false
    @State private var animateBackgroundIcons = false
    @State var navigateToUserList = false
    @State private var isListPressed = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景グラデーション
                LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                // 背景にふわっと動く小アイコン
                ForEach(0..<15, id: \.self) { i in
                    FloatingIconView()
                        .offset(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: -300...300))
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true),
                            value: animateBackgroundIcons
                        )
                }
                
                ScrollView {
                    VStack(spacing: 40) {
                        // 名前表示カード
                        Text(settings.name.isEmpty ? NSLocalizedString("enter_name", comment: "") : "\(settings.name) " + NSLocalizedString("skin", comment: ""))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                        
                        // メインボタン（丸＋アイコン＋押しアニメ）
                        Button {
                            navigateToFeeling = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 120, height: 120)
                                    .shadow(color: .purple.opacity(0.6), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "arrow.right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                        }
                        .scaleEffect(isPressed ? 0.9 : (animateButton ? 1.2 : 1.0))
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animateButton)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isPressed = true }
                                .onEnded { _ in isPressed = false }
                        )
                        .onAppear { animateButton = true }
                        .navigationDestination(isPresented: $navigateToFeeling) {
                            FeelingSelectionView().environmentObject(settings)
                        }
                        
                        Spacer(minLength: 50) // ← この Spacer で下ボタンを押し下げる
                        
                        // 相手変更ボタン（半透明白＋黒文字）
                        Button(NSLocalizedString("change_partner", comment: "")) {
                            settings.name = ""
                            settings.selectedGender = ""
                        }
                        .font(.title2)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(20)
                        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 3)
                        .foregroundColor(.black)
                        
                        // 登録相手リストボタン
                        if !settings.userList.isEmpty {
                            NavigationLink(destination: UserListView().environmentObject(settings)) {
                                Text(NSLocalizedString("registered_user_list", comment: ""))
                                    .font(.title3)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 30)
                                    .background(Color.blue.opacity(0.5))
                                    .cornerRadius(20)
                                    .shadow(color: .blue.opacity(0.5), radius: 5, x: 0, y: 3)
                                    .foregroundColor(.white)
                                    .scaleEffect(isListPressed ? 0.95 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: isListPressed)
                                    .simultaneousGesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { _ in isListPressed = true }
                                            .onEnded { _ in isListPressed = false }
                                    )
                            }
                        }
                    }
                    .padding(.bottom, 20) // 下に少し余白を追加
                }

                .navigationTitle(NSLocalizedString("main_title", comment: "メイン画面"))
                .navigationBarTitleDisplayMode(.inline)
                .onAppear { animateBackgroundIcons = true }
            }
        }
    }
    
    // 背景でふわふわ動く小アイコンビュー
    struct FloatingIconView: View {
        @State private var scale: CGFloat = 0.5
        private let iconNames = ["star.fill", "circle.fill", "diamond.fill", "triangle.fill"]
        
        var body: some View {
            let name = iconNames.randomElement()!
            Image(systemName: name)
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .foregroundColor(.white.opacity(Double.random(in: 0.2...0.5)))
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: Double.random(in: 2...4)).repeatForever(autoreverses: true)) {
                        scale = 1.0
                    }
                }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(UserSettings())
}
