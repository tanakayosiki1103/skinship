import Foundation
import UIKit
import UnityAds

// MARK: - Unity Ads Manager
final class UnityAdsManager: NSObject {
    
    static let shared = UnityAdsManager()
    
    // Unity Dashboard
    private let gameId = "5998944"
    private let placementId = "machingunity"
    
    // Counters
    private let hugKey = "unity_ads_hug_count"
    private let specialKey = "unity_ads_special_count"
    
    // State
    private var isInitialized = false
    private var adReady = false
    private var isLoading = false
    
    // MARK: - Initialize
    func initialize() {
        guard !isInitialized else { return }
        isInitialized = true
        
        // 🔽🔽🔽 ここが「テスト用 / 本番用」の切り替えポイント 🔽🔽🔽
#if DEBUG
        let testMode = true      // ← デバッグビルド（Xcode実行・Simulator）
        //    → Unity のテスト広告が出る（収益なし）
#else
        let testMode = false     // ← Releaseビルド（TestFlight / App Store）
        //    → 本番広告が出る（収益対象）
#endif
        // 🔼🔼🔼 ここまで 🔼🔼🔼
        
        UnityAds.initialize(
            gameId,
            testMode: testMode,
            initializationDelegate: self
        )
    }

    
    // MARK: - Public: show checks
    @discardableResult
    func showAdIfNeededAfterHug() -> Bool {
        let count = increment(hugKey)
        if count % 15 == 0 {
            show()
            return true
        }
        return false
    }
    
    @discardableResult
    func showAdIfNeededAfterSpecial() -> Bool {
        let count = increment(specialKey)
        if count % 5 == 0 {
            show()
            return true
        }
        return false
    }
    
    // MARK: - Internals
    private func increment(_ key: String) -> Int {
        let next = UserDefaults.standard.integer(forKey: key) + 1
        UserDefaults.standard.set(next, forKey: key)
        return next
    }
    
    private func loadAdIfNeeded() {
        guard !isLoading else { return }
        isLoading = true
        UnityAds.load(placementId, loadDelegate: self)
    }
    
    private func show() {
        // ready じゃないならロード維持（止まり防止）
        guard adReady else {
            loadAdIfNeeded()
            return
        }
        
        guard let rootVC = UIApplication.shared.topMostViewController() else {
            // root VC が取れない場合でも次回に備えてロードは維持
            loadAdIfNeeded()
            return
        }
        
        UnityAds.show(
            rootVC,
            placementId: placementId,
            showDelegate: self
        )
    }
}

// MARK: - UnityAdsInitializationDelegate
extension UnityAdsManager: UnityAdsInitializationDelegate {
    
    func initializationComplete() {
        adReady = false
        isLoading = false
        loadAdIfNeeded()
    }
    
    func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        // 初期化失敗時は再試行できるように戻す
        isInitialized = false
        adReady = false
        isLoading = false
    }
}

// MARK: - UnityAdsLoadDelegate
extension UnityAdsManager: UnityAdsLoadDelegate {
    
    func unityAdsAdLoaded(_ placementId: String) {
        isLoading = false
        adReady = true
    }
    
    func unityAdsAdFailed(
        toLoad placementId: String,
        withError error: UnityAdsLoadError,
        withMessage message: String
    ) {
        isLoading = false
        adReady = false
        
        // 軽いリトライ（無限連打防止で待つ）
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.loadAdIfNeeded()
        }
    }
}

// MARK: - UnityAdsShowDelegate
extension UnityAdsManager: UnityAdsShowDelegate {
    
    func unityAdsShowStart(_ placementId: String) {
        adReady = false
    }
    
    func unityAdsShowComplete(
        _ placementId: String,
        withFinish state: UnityAdsShowCompletionState
    ) {
        // 次の広告を準備
        loadAdIfNeeded()
    }
    
    func unityAdsShowFailed(
        _ placementId: String,
        withError error: UnityAdsShowError,
        withMessage message: String
    ) {
        adReady = false
        
        // 失敗しても次に備えてロード
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.loadAdIfNeeded()
        }
    }
    
    func unityAdsShowClick(_ placementId: String) {}
}


