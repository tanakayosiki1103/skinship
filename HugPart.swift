//
//  HugPart.swift
//  Skinship
//
//  Created by 田中　よしき on 2025/10/26.
//
import Foundation
import SwiftUI   // （必要なら）
enum HugPart: String, CaseIterable {
    case arm, leg, chest, waist, hair, nose, lips
    
    var localizedName: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}


