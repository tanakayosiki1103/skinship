//import SwiftUI
//import GoogleMobileAds
//import UIKit
//
//class InterstitialAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
//    @Published private var interstitial: InterstitialAd?
//    
//    // trueならテスト用、falseなら本番用
//    var isTestMode: Bool = true
//    
//    private var adUnitID: String {
//        isTestMode
//        ? "ca-app-pub-3940256099942544/4411468910" // テスト用
//        : "ca-app-pub-6691505064466333/8139093510" // 本番用
//    }
//    
//    override init() {
//        super.init()
//        loadAd()
//    }
//    
//    func loadAd() {
//        let request = Request()
//        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
//            if let error = error {
//                print("❌ 広告の読み込み失敗: \(error.localizedDescription)")
//                return
//            }
//            self?.interstitial = ad
//            self?.interstitial?.fullScreenContentDelegate = self
//            print("✅ 広告読み込み完了")
//        }
//    }
//    
//    func showAd(from rootViewController: UIViewController) {
//        if let ad = interstitial {
//            ad.present(from: rootViewController)
//            print("✅ 広告表示完了")
//            loadAd() // 表示後すぐに次の広告を準備
//        } else {
//            print("⚠️ 広告がまだ読み込まれていません。")
//        }
//    }
//    
//    // MARK: - FullScreenContentDelegate
//    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
//        print("📱 広告が閉じられたので再読み込みします")
//        loadAd()
//    }
//}
