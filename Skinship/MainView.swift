import SwiftUI

// MARK: - Neon / Glass Helpers



// MARK: - Particles (軽量: 事前生成 + 変位だけ)
private struct Particle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let alpha: CGFloat
    let speed: Double
    let delay: Double
}
private struct ParticleView: View {
    let p: Particle
    let animate: Bool
    var body: some View {
        Circle()
            .fill(.white.opacity(p.alpha))
            .frame(width: p.size, height: p.size)
            .blur(radius: 0.3)
            .offset(x: p.x, y: p.y + (animate ? 34 : -34))
            .animation(
                .easeInOut(duration: p.speed)
                .delay(p.delay)
                .repeatForever(autoreverses: true),
                value: animate
            )
    }
}

struct MainView: View {
    @EnvironmentObject var settings: UserSettings
    
    @State private var navigateToFeeling = false
    @State private var navigateToNameInput = false
    
    @State private var pulse = false
    @State private var press = false
    @State private var bgAnim = false
    @State private var scan = false
    @State private var showUserList = false
    @State private var isEditingUsers = false
    
    private let particles: [Particle] = (0..<20).map { _ in
        Particle(
            x: .random(in: -180...180),
            y: .random(in: -420...260),
            size: .random(in: 2...7),
            alpha: .random(in: 0.10...0.26),
            speed: .random(in: 3.2...6.0),
            delay: .random(in: 0...1.2)
        )
    }
    
    var body: some View {
        ZStack {
            futuristicBackground
                .allowsHitTesting(false)
            
//            VStack {
//                Spacer(minLength: 0)
//                
//                VStack(spacing: 18) {
//                    topHUD
//                    heroCard
//                    actionGrid
//                }
//                .padding(.horizontal, 16)
//                .frame(maxWidth: 560)
//                .frame(maxWidth: .infinity)
//                
//                Spacer(minLength: 0)
//            }
//            .padding(.vertical, 20)

            VStack(spacing: 18) {
                topHUD
                heroCard
                actionGrid
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity, alignment: .top)

            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(NSLocalizedString("main_title", comment: "メイン画面"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black.opacity(0.35), for: .navigationBar)
        .navigationDestination(isPresented: $navigateToFeeling) {
            FeelingSelectionView().environmentObject(settings)
        }
        .navigationDestination(isPresented: $navigateToNameInput) {
            NameInputView().environmentObject(settings)
        }
        .onAppear {
            pulse = true
            bgAnim = true
            withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                scan.toggle()
            }
        }
    }
    
    // MARK: - Background (近未来: 深い宇宙 + ネオン + スキャンライン)
    private var futuristicBackground: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.06, green: 0.03, blue: 0.12),
                        Color(red: 0.02, green: 0.07, blue: 0.14)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Circle()
                    .fill(Color.cyan.opacity(0.18))
                    .frame(width: 420, height: 420)
                    .blur(radius: 45)
                    .offset(x: bgAnim ? 120 : -120, y: bgAnim ? -220 : -120)
                    .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: bgAnim)
                
                Circle()
                    .fill(Color.purple.opacity(0.18))
                    .frame(width: 520, height: 520)
                    .blur(radius: 55)
                    .offset(x: bgAnim ? -120 : 140, y: bgAnim ? 220 : 140)
                    .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: bgAnim)
                
                ForEach(particles) { p in
                    ParticleView(p: p, animate: bgAnim)
                }
                
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.12), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 120)
                    .blur(radius: 10)
//                    .offset(y: scan ? geo.size.height : -geo.size.height)
                    .offset(y: scan ? (geo.size.height + 300) : -(geo.size.height + 300))

                    .blendMode(.screen)
                    .allowsHitTesting(false)
            }
            .frame(width: geo.size.width, height: geo.size.height)
           /* .clipped() */  // ← mask の代わりにこれでもOK
        }
        .ignoresSafeArea()
    }

    
    // MARK: - Top HUD
    private var topHUD: some View {
        HStack(spacing: 12) {
            Label(
                NSLocalizedString("main_hud_status", comment: "接続中"),
                systemImage: "dot.radiowaves.left.and.right"
            )
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(.white.opacity(0.85))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .glassCard(0.12)
            
            Spacer()
        }
        .padding(.bottom, 6)
    }

    
    // MARK: - Hero
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(NSLocalizedString("main_future_title", comment: "NEO SKINSHIP"))
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .tracking(1.2)
                    
                    if !settings.name.isEmpty {
                        Text(String(format: NSLocalizedString("skin_with", comment: ""), settings.name))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)              // ✅ 折り返し見やすい
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true) // ✅ これ重要（親制限で…になるのを防ぐ）
                            .minimumScaleFactor(0.6)                      // ✅ 0.75だとSEで足りないことが多い
                            .padding(.horizontal, 16)                     // ✅ 端ギリギリを避ける

                    } else {
                        Text(NSLocalizedString("main_future_sub", comment: "あなたの気分に合わせて、触れ合いの演出へ"))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.82))
                            .lineLimit(3)
                            .minimumScaleFactor(0.85)
                    }
                }
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.white.opacity(0.08))
                        .frame(width: 56, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(.white.opacity(0.20), lineWidth: 1)
                        )
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white.opacity(0.90))
                        .neonGlow(0.40, radius: 14)
                }
            }
            
            // 主役CTA（近未来: hex風）
            Button {
                navigateToFeeling = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white.opacity(0.95))
                        .neonGlow(0.35, radius: 12)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(NSLocalizedString("main_future_cta", comment: "START"))
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .tracking(1.6)
                        Text(NSLocalizedString("main_future_cta_sub", comment: "気分を選んで、演出へ"))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.white.opacity(0.14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(.white.opacity(0.18), lineWidth: 1)
                        )
                )
                .overlay(
                    // ネオンの細いハイライト
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(colors: [.white.opacity(0.25), .clear, .white.opacity(0.12)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                )
                .shadow(color: .white.opacity(0.10), radius: 18, x: 0, y: 10)
            }
            .buttonStyle(.plain)
            .scaleEffect(press ? 0.98 : (pulse ? 1.01 : 1.0))
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in press = true }
                    .onEnded { _ in press = false }
            )
        }
        .padding(18)
        .glassCard(0.16)
    }
    
    // MARK: - Action Grid (2枚カードで近未来UIっぽく)
    private var actionGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                actionCard(
                    titleKey: "change_partner",
                    subKey: "main_action_change_sub",
                    systemImage: "person.crop.circle.badge.arrow.trianglehead.counterclockwise",
                    tint: .cyan
                ) {
                    settings.clearPartner()
                    navigateToNameInput = true
                }
                
                NavigationLink {
                    UserListView(isEditing: $isEditingUsers)   // ✅ これを渡す
                        .environmentObject(settings)
                } label: {
                    actionCardLabel(
                        titleKey: "registered_user_list",
                        subKey: "main_action_list_sub",
                        systemImage: "list.bullet.rectangle",
                        tint: .purple
                    )
                }
                .buttonStyle(.plain)

                .disabled(settings.userList.isEmpty)
                .opacity(settings.userList.isEmpty ? 0.45 : 1.0)
            }
        }
        .padding(.top, 6)
    }
    
    private func actionCard(
        titleKey: String,
        subKey: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            actionCardLabel(
                titleKey: titleKey,
                subKey: subKey,
                systemImage: systemImage,
                tint: tint
            )
        }
        .buttonStyle(.plain)
    }
    
    private func actionCardLabel(
        titleKey: String,
        subKey: String,
        systemImage: String,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white.opacity(0.92))
                    .padding(10)
                    .background(tint.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(tint.opacity(0.35), lineWidth: 1)
                    )
                
                Spacer()
            }
            
            Text(NSLocalizedString(titleKey, comment: ""))
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            
            Text(NSLocalizedString(subKey, comment: ""))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        .glassCard(0.14)
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(tint.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 16, x: 0, y: 10)
    }
    
  
}

#Preview {
    NavigationStack {
        MainView()
            .environmentObject(UserSettings())
    }
}

