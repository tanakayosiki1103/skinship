//
//  PressableButtonStyle.swift
//  Skinship
//
//  Created by 田中　よしき on 2025/12/25.
//

import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    var yOffset: CGFloat = 2
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .offset(y: configuration.isPressed ? yOffset : 0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(
                .spring(response: 0.22, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}

