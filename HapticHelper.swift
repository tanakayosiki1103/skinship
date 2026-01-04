//
//  HapticHelper.swift
//  Skinship
//
//  Created by 田中　よしき on 2025/12/24.
//

import UIKit

func impactHaptic(
    style: UIImpactFeedbackGenerator.FeedbackStyle = .medium
) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}

