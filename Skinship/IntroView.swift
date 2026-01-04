//
//  IntroView.swift
//  Skinship
//
//  Created by 田中 よしき on 2025/12/20.
//

import SwiftUI

struct IntroView: View {
    
    // 背景
    private let bgColors = [
        Color(red: 0.50, green: 0.30, blue: 0.70),
        Color(red: 0.35, green: 0.50, blue: 0.80)
    ]
    
    // 段落キー（ローカライズ）
    private let paragraphKeys = [
        "intro_p1", "intro_p2", "intro_p3", "intro_p4", "intro_p5", "intro_p6"
    ]
    
    @State private var currentIndex = 0
    @State private var paragraphOpacity: Double = 0.0
    @State private var showButton = false
    @State private var isSkipped = false
    @State private var dontShowAgain = false
    
    let onFinish: (Bool) -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 背景
                LinearGradient(
                    gradient: Gradient(colors: bgColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // テキスト（ローカライズ）
                    Text(NSLocalizedString(paragraphKeys[currentIndex], comment: "Intro paragraph"))
                        .foregroundColor(.white.opacity(0.92))
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .frame(width: geo.size.width * 0.8)
                        .opacity(paragraphOpacity)
                    
                    Spacer()
                    
                    // 最後の画面
                    if showButton {
                        VStack(spacing: 16) {
                            Button {
                                onFinish(dontShowAgain)
                            } label: {
                                Text(NSLocalizedString("intro_start", comment: "Intro start"))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 36)
                                    .padding(.vertical, 14)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.25))
                                    )
                            }
                            
                            Button {
                                dontShowAgain.toggle()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: dontShowAgain ? "checkmark.square" : "square")
                                    Text(NSLocalizedString("intro_dont_show_again", comment: "Intro dont show again"))
                                }
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.bottom, 40)
                        .transition(.opacity)
                    }
                }
                
                // スキップ
                if !showButton {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(NSLocalizedString("intro_skip", comment: "Intro skip")) {
                                skipToEnd()
                            }
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .onAppear {
                showNextParagraph()
            }
        }
    }
    
    // MARK: - 段落制御
    
    private func showNextParagraph() {
        if isSkipped { return }
        
        paragraphOpacity = 0.0
        
        withAnimation(.easeInOut(duration: 2.8)) {
            paragraphOpacity = 1.0
        }
        
        let isLast = currentIndex == paragraphKeys.count - 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if isSkipped { return }
            
            if isLast {
                withAnimation(.easeInOut(duration: 2.0)) {
                    showButton = true
                }
            } else {
                withAnimation(.easeInOut(duration: 2.8)) {
                    paragraphOpacity = 0.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.9) {
                    if isSkipped { return }
                    currentIndex += 1
                    showNextParagraph()
                }
            }
        }
    }
    
    // MARK: - スキップ
    
    private func skipToEnd() {
        isSkipped = true
        currentIndex = paragraphKeys.count - 1
        paragraphOpacity = 1.0
        
        withAnimation(.easeInOut(duration: 1.5)) {
            showButton = true
        }
    }
}

#Preview {
    IntroView { dontShowAgain in
        print("Intro finished: \(dontShowAgain)")
    }
}
