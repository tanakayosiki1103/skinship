//
//  UIApplication+TopMost.swift
//  Skinship
//
//  Created by 田中　よしき on 2025/12/28.
//
import UIKit

extension UIApplication {
    
    /// 現在 foregroundActive な Scene から最前面の ViewController を取得
    func topMostViewController() -> UIViewController? {
        
        let activeScene = connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first
        
        guard let windowScene = activeScene else { return nil }
        
        guard let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var topController = window.rootViewController
        while let presented = topController?.presentedViewController {
            topController = presented
        }
        return topController
    }
}

