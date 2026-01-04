//
//  NeoUI.swift
//  Skinship
//
//  Created by 田中　よしき on 2025/12/26.
//

import SwiftUI

// MARK: - Neo Theme
enum NeoTheme {
    static let corner: CGFloat = 26
    static let cardOpacity: Double = 0.14
    static let strokeOpacity: Double = 0.18
}

// MARK: - Glass Card
struct GlassCardModifier: ViewModifier {
    var opacity: Double = NeoTheme.cardOpacity
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial.opacity(opacity))
            .clipShape(RoundedRectangle(cornerRadius: NeoTheme.corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: NeoTheme.corner, style: .continuous)
                    .stroke(.white.opacity(NeoTheme.strokeOpacity), lineWidth: 1)
            )
    }
}
extension View {
    func glassCard(_ opacity: Double = NeoTheme.cardOpacity) -> some View {
        modifier(GlassCardModifier(opacity: opacity))
    }
}

// MARK: - Neon Stroke / Glow
extension View {
    func neonStroke(_ tint: Color, width: CGFloat = 1) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: NeoTheme.corner, style: .continuous)
                .stroke(tint.opacity(0.22), lineWidth: width)
        )
    }
    func neonGlow(_ opacity: Double = 0.35, radius: CGFloat = 14) -> some View {
        shadow(color: .white.opacity(opacity), radius: radius, x: 0, y: 0)
    }
}

enum NeoBackgroundTheme: CaseIterable {
    case aqua, sky, lavender, peach, mint, rose
    
    var base: [Color] {
        switch self {
        case .aqua:
            return [
                Color(red: 0.06, green: 0.10, blue: 0.18),
                Color(red: 0.10, green: 0.26, blue: 0.34),
                Color(red: 0.06, green: 0.18, blue: 0.28)
            ]
        case .sky:
            return [
                Color(red: 0.05, green: 0.12, blue: 0.22),
                Color(red: 0.12, green: 0.30, blue: 0.42),
                Color(red: 0.08, green: 0.22, blue: 0.36)
            ]
        case .lavender:
            return [
                Color(red: 0.10, green: 0.07, blue: 0.20),
                Color(red: 0.22, green: 0.14, blue: 0.34),
                Color(red: 0.14, green: 0.10, blue: 0.28)
            ]
        case .peach:
            return [
                Color(red: 0.16, green: 0.08, blue: 0.14),
                Color(red: 0.32, green: 0.18, blue: 0.18),
                Color(red: 0.22, green: 0.12, blue: 0.10)
            ]
        case .mint:
            return [
                Color(red: 0.06, green: 0.14, blue: 0.16),
                Color(red: 0.12, green: 0.30, blue: 0.26),
                Color(red: 0.08, green: 0.22, blue: 0.18)
            ]
        case .rose:
            return [
                Color(red: 0.14, green: 0.06, blue: 0.14),
                Color(red: 0.30, green: 0.14, blue: 0.26),
                Color(red: 0.22, green: 0.10, blue: 0.18)
            ]
        }
    }
    
    var orb1: Color {
        switch self {
        case .aqua: return .cyan
        case .sky: return .blue
        case .lavender: return .purple
        case .peach: return .orange
        case .mint: return .mint
        case .rose: return .pink
        }
    }
    
    var orb2: Color {
        switch self {
        case .aqua: return .blue
        case .sky: return .cyan
        case .lavender: return .indigo
        case .peach: return .pink
        case .mint: return .cyan
        case .rose: return .purple
        }
    }
}


// MARK: - Neo Background (軽量版)


struct NeoBackground: View {
    var theme: NeoBackgroundTheme = .aqua
    @State private var anim = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: theme.base,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Circle()
                    .fill(theme.orb1.opacity(0.18))
                    .frame(width: 420, height: 420)
                    .blur(radius: 45)
                    .offset(x: anim ? 120 : -120, y: anim ? -220 : -120)
                    .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: anim)
                
                Circle()
                    .fill(theme.orb2.opacity(0.18))
                    .frame(width: 520, height: 520)
                    .blur(radius: 55)
                    .offset(x: anim ? -120 : 140, y: anim ? 220 : 140)
                    .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: anim)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
            .contentShape(Rectangle())
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear { anim = true }
        // ✅ テーマ変更時にふわっと切替
        .transition(.opacity)
    }
}



// MARK: - Neo Button (カード型)
struct NeoPrimaryButton: View {
    let title: String
    let subtitle: String?
    let systemImage: String
    let action: () -> Void
    
    init(_ title: String, subtitle: String? = nil, systemImage: String = "arrow.right.circle.fill", action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white.opacity(0.95))
                    .neonGlow(0.35, radius: 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.78))
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .glassCard(0.14)
        }
        .buttonStyle(.plain)
    }
}

