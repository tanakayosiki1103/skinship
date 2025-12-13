import Foundation
import UIKit
import UnityAds

class UnityAdsManager: NSObject, ObservableObject,
                       UnityAdsInitializationDelegate,
                       UnityAdsLoadDelegate,
                       UnityAdsShowDelegate {
    
    static let shared = UnityAdsManager()
    
    private let gameId = "5998944"
    private let placementId = "machingunity"
    
    private var isInitialized = false
    private var adReady = false
    
    private override init() {
        super.init()
    }
    
    func initialize() {
        guard !isInitialized else { return }
        
        // ⚠️ 本番リリース時は testMode = false に変更すること
        //     - true の場合はテスト広告（ダミー）が表示される
        //     - false の場合は本番広告が表示され、収益が発生
        UnityAds.initialize(gameId, testMode: true, initializationDelegate: self)
    }

    
    func load() {
        UnityAds.load(placementId, loadDelegate: self)
    }
    
    func show() {
        guard adReady else {
            print("⚠️ 広告まだ準備中")
            return
        }
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController else {
            print("❌ rootViewController 取得失敗")
            return
        }
        UnityAds.show(rootVC, placementId: placementId, showDelegate: self)
    }
    
    // =================================================
    // MARK: UnityAdsInitializationDelegate
    // =================================================
    func initializationComplete() {
        print("🚀 Unity Ads 初期化完了")
        isInitialized = true
        load() // 初期化後すぐロード
    }
    
    func initializationFailed(
        _ error: UnityAdsInitializationError,
        withMessage message: String
    ) {
        print("❌ Unity Ads 初期化失敗: \(message)")
    }
    
    // =================================================
    // MARK: UnityAdsLoadDelegate
    // =================================================
    func unityAdsAdLoaded(_ placementId: String) {
        print("✅ Unity Ads 読み込み完了: \(placementId)")
        adReady = true // 読み込み完了フラグ
    }
    
    func unityAdsAdFailed(
        toLoad placementId: String,
        withError error: UnityAdsLoadError,
        withMessage message: String
    ) {
        print("❌ Unity Ads 読み込み失敗: \(message)")
        adReady = false
    }
    
    // =================================================
    // MARK: UnityAdsShowDelegate
    // =================================================
    func unityAdsShowStart(_ placementId: String) {
        print("▶️ Unity Ads 表示開始")
        adReady = false // 表示中は未準備に戻す
    }
    
    func unityAdsShowClick(_ placementId: String) {
        print("🖱 Unity Ads クリック")
    }
    
    func unityAdsShowComplete(
        _ placementId: String,
        withFinish state: UnityAdsShowCompletionState
    ) {
        print("✅ Unity Ads 表示完了")
        load() // 次回用に再ロード
    }
    
    func unityAdsShowFailed(
        _ placementId: String,
        withError error: UnityAdsShowError,
        withMessage message: String
    ) {
        print("❌ Unity Ads 表示失敗: \(message)")
    }
    
    // MARK: - 表示回数管理
    private var actionCount = 0
    
    func showAdIfNeeded() {
        actionCount += 1
        if actionCount % 15 == 0 {
            show() // ← この時だけ表示される
        }
    }

}
