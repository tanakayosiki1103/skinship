//
//  HugPart.swift
//  Skinship
//
//  Created by 田中 よしき on 2025/12/20.
//

import Foundation

enum HugPart: CaseIterable, Hashable {
    case arm, leg, chest, waist, hair, nose, lips
    
    /// 表示用（ローカライズ済み部位名）
    var localizedName: String {
        NSLocalizedString(titleKey, comment: "")
    }
    
    /// Localizable.strings のキー
    private var titleKey: String {
        switch self {
        case .arm:   return "hug_part_arm"
        case .leg:   return "hug_part_leg"
        case .chest: return "hug_part_chest"
        case .waist: return "hug_part_waist"
        case .hair:  return "hug_part_hair"
        case .nose:  return "hug_part_nose"
        case .lips:  return "hug_part_lips"
        }
    }
}
