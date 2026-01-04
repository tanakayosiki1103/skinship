import SwiftUI

// ✅ ① 本体
struct HugFeeling: Identifiable, Hashable {
    let id = UUID()
    let key: String
    let title: String
    let hugMessage: String
    let lines: [String]
    let color: Color
}

// ✅ ② extension
extension HugFeeling {
    
    static let hotto = HugFeeling(
        key: "hotto",
        title: NSLocalizedString("feeling_hotto", comment: ""),
        hugMessage: NSLocalizedString("hug_hotto", comment: ""),
        lines: [
            "hotto_line1","hotto_line2","hotto_line3","hotto_line4","hotto_line5"
        ],
        color: .blue
    )
    
    static let calm = HugFeeling(
        key: "calm",
        title: NSLocalizedString("feeling_calm", comment: ""),
        hugMessage: NSLocalizedString("hug_calm", comment: ""),
        lines: [
            "calm_line1","calm_line2","calm_line3","calm_line4","calm_line5"
        ],
        color: .green
    )
    
    static let balanced = HugFeeling(
        key: "balanced",
        title: NSLocalizedString("feeling_balanced", comment: ""),
        hugMessage: NSLocalizedString("hug_balanced", comment: ""),
        lines: [
            "balanced_line1","balanced_line2","balanced_line3","balanced_line4","balanced_line5"
        ],
        color: .cyan
    )
    
    static let soft = HugFeeling(
        key: "soft",
        title: NSLocalizedString("feeling_soft", comment: ""),
        hugMessage: NSLocalizedString("hug_soft", comment: ""),
        lines: [
            "soft_line1","soft_line2","soft_line3","soft_line4"
        ],
        color: .pink
    )
    
    static let rest = HugFeeling(
        key: "rest",
        title: NSLocalizedString("feeling_rest", comment: ""),
        hugMessage: NSLocalizedString("hug_rest", comment: ""),
        lines: [
            "rest_line1","rest_line2","rest_line3","rest_line4","rest_line5"
        ],
        color: .purple
    )
    
    static let lonely = HugFeeling(
        key: "lonely",
        title: NSLocalizedString("feeling_lonely", comment: ""),
        hugMessage: NSLocalizedString("hug_lonely", comment: ""),
        lines: [
            "lonely_line1","lonely_line2","lonely_line3","lonely_line4","lonely_line5"
        ],
        color: .orange
    )
    
    static let allCases: [HugFeeling] = [
        .hotto, .calm, .balanced, .soft, .rest, .lonely
    ]
    
    // ✅ %@ を使わないなら、これは「使わない」でOK（残しても害はない）
    func localizedLine(_ key: String, name: String) -> String {
        let format = NSLocalizedString(key, comment: "")
        // "%@" が入ってる行だけ name を差し込む（入ってなければそのまま返る）
        return format.contains("%@") ? String(format: format, name) : format
    }

}
extension HugFeeling {
    // 見た目用：背景グラデ（HugFeelingViewのZStack背景で使う）
    var gradient: LinearGradient {
        LinearGradient(
            colors: [
                color.opacity(0.55),
                color.opacity(0.25),
                Color.black.opacity(0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // 見た目用：カード背景に使う“薄い色”
    var cardTint: Color {
        color.opacity(0.18)
    }
    
    // 見た目用：アクセント（ボタンや枠線に使う）
    var accent: Color {
        color.opacity(0.95)
    }
}
