//
//  SpecialSparkleButton.swift
//  Skinship
//
//  Created by 田中　よしき on 2025/12/26.
//
import SwiftUI

struct SpecialSparkleButton: View {
    let title: String
    @State private var shineX: CGFloat = -0.6
    @State private var twinkle = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.pink.opacity(0.95),
                            Color.purple.opacity(0.95),
                            Color.blue.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .white.opacity(0.22), radius: 18, y: 8)
                .shadow(color: .pink.opacity(0.18), radius: 28, y: 14)
            
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(.degrees(20))
                    .frame(width: geo.size.width * 0.35)
                    .offset(x: geo.size.width * shineX)
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .symbolRenderingMode(.hierarchical)
                    .opacity(twinkle ? 1.0 : 0.55)
                    .scaleEffect(twinkle ? 1.08 : 0.96)
                
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                
                Image(systemName: "sparkles")
                    .symbolRenderingMode(.hierarchical)
                    .opacity(twinkle ? 0.85 : 0.45)
                    .scaleEffect(twinkle ? 1.02 : 0.94)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
        }
        .frame(height: 58)
        .onAppear {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                shineX = 1.2
            }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                twinkle.toggle()
            }
        }
    }
}

#Preview("SpecialSparkleButton") {
    ZStack {
        Color.black.ignoresSafeArea()
        SpecialSparkleButton(title: "スペシャルスキンシップ")
            .padding()
    }
}

