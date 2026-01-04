import SwiftUI
import AVFoundation
import UIKit




// MARK: - UserSettings
final class UserSettings: ObservableObject {
    
    // ===== Keys =====
    private let hasNameKey = "hasName"
    private let partnerNameKey = "partnerName"
    private let selectedGenderKey = "selectedGender"
    
    private let userListKey = "userList"
    private let userGenderMapKey = "userGenderMap"
    
    private let typeSpeedKey = "typeSpeedByFeeling"
    private let introDontShowAgainKey = "intro_dont_show_again"
    
    private let specialLineKey = "specialLine"
    private let specialLinesKey = "specialLines"
    
    // ===== 基本情報（必要なら後で永続化）=====
    @Published var name2: String = ""                 // ユーザー本人の名前（未永続化）
    @Published var partnerGender: String = ""         // 未使用なら後で削除OK
    
    // ===== 相手情報（再起動で保持）=====
    @Published var name: String = "" {                // 相手の名前（現在選択中）
        didSet { savePartnerState() }
    }
    
    @Published var hasName: Bool = false {            // 相手登録済みフラグ
        didSet { savePartnerState() }
    }
    
    /// "male" or "female"（再起動で保持）
    @Published var selectedGender: String = "male" {
        didSet { savePartnerState() }
    }
    
    /// Introを今後表示しない（再起動で保持）
    @Published var introDontShowAgain: Bool = false {
        didSet { UserDefaults.standard.set(introDontShowAgain, forKey: introDontShowAgainKey) }
    }
    
    @Published var selectedFeeling: HugFeeling? = nil
    
    // ===== 音声 =====
    @Published var isVoiceEnabled: Bool = true
    @Published var selectedPersonality: Personality = .cheerful
    
    // ===== ハグ回数（未永続化）=====
    @Published var hugCounts: [String: Int] = [:]
    
    // ===== 相手一覧（再起動で保持）=====
    @Published var userList: [String] = [] {
        didSet { saveUserList() }
    }
    
    /// name -> "male"/"female"（再起動で保持）
    @Published var userGenderMap: [String: String] = [:] {
        didSet { saveUserGenderMap() }
    }
    
    // ===== タイプ速度（再起動で保持）=====
    @Published var typeSpeedByFeeling: [String: Double] = [
        "hotto": 0.04,
        "calm": 0.05,
        "balanced": 0.045,
        "soft": 0.035,
        "rest": 0.06,
        "lonely": 0.05
    ] {
        didSet { saveTypeSpeedByFeeling() }
    }
    
    // ===== スペシャル（再起動で保持）=====
    @Published var specialLine: String = "" {
        didSet { UserDefaults.standard.set(specialLine, forKey: specialLineKey) }
    }
    
    @Published var specialLines: [SpecialLineItem] = [] {
        didSet { saveSpecialLines() }
    }
    
    private let speaker = AVSpeechSynthesizer()
    
    // MARK: - Init
    init() {
        loadPartnerState()
        loadUserList()
        loadUserGenderMap()
        loadTypeSpeedByFeeling()
        normalizeGenderMap() 
        introDontShowAgain = UserDefaults.standard.bool(forKey: introDontShowAgainKey)
        
        specialLine = UserDefaults.standard.string(forKey: specialLineKey) ?? ""
        loadSpecialLines()
    }
    
    // MARK: - Partner Save/Load
    private func savePartnerState() {
        UserDefaults.standard.set(hasName, forKey: hasNameKey)
        UserDefaults.standard.set(name, forKey: partnerNameKey)
        UserDefaults.standard.set(selectedGender, forKey: selectedGenderKey)
    }
    
    private func loadPartnerState() {
        let savedHasName = UserDefaults.standard.bool(forKey: hasNameKey)
        let savedName = UserDefaults.standard.string(forKey: partnerNameKey) ?? ""
        let savedGender = UserDefaults.standard.string(forKey: selectedGenderKey) ?? "male"
        
        name = savedName
        selectedGender = savedGender
        hasName = savedHasName && !savedName.isEmpty
    }
    // MARK: - 既存ユーザー救済
    private func normalizeGenderMap() {
        var changed = false
        for name in userList where userGenderMap[name] == nil {
            userGenderMap[name] = "male"   // デフォルト（好みで female でもOK）
            changed = true
        }
        if changed {
            saveUserGenderMap()
        }
    }

    
    // MARK: - UserList Save/Load
    private func saveUserList() {
        UserDefaults.standard.set(userList, forKey: userListKey)
    }
    
    private func loadUserList() {
        userList = UserDefaults.standard.stringArray(forKey: userListKey) ?? []
    }
    
    // MARK: - UserGenderMap Save / Load
    private func saveUserGenderMap() {
        if let data = try? JSONEncoder().encode(userGenderMap) {
            UserDefaults.standard.set(data, forKey: userGenderMapKey)
        }
    }
    private func loadUserGenderMap() {
        guard
            let data = UserDefaults.standard.data(forKey: userGenderMapKey),
            let map = try? JSONDecoder().decode([String: String].self, from: data)
        else {
            userGenderMap = [:]
            return
        }
        userGenderMap = map
    }
    
  

    
    // MARK: - Type Speed Save/Load
    func typeSpeed(for feelingKey: String) -> Double {
        typeSpeedByFeeling[feelingKey] ?? 0.05
    }
    
    private func saveTypeSpeedByFeeling() {
        if let data = try? JSONEncoder().encode(typeSpeedByFeeling) {
            UserDefaults.standard.set(data, forKey: typeSpeedKey)
        }
    }
    
    private func loadTypeSpeedByFeeling() {
        guard
            let data = UserDefaults.standard.data(forKey: typeSpeedKey),
            let dict = try? JSONDecoder().decode([String: Double].self, from: data)
        else { return }
        typeSpeedByFeeling = dict
    }
    
    // MARK: - Speech
    func speak(_ text: String) {
        guard isVoiceEnabled else { return }
        
        if speaker.isSpeaking {
            speaker.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voiceForSelectedGender() ?? AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = selectedPersonality.speechRate
        utterance.pitchMultiplier = selectedPersonality.pitchMultiplier
        speaker.speak(utterance)
    }
    
    private func voiceForSelectedGender() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "ja-JP" }
        let wantFemale = (selectedGender == "female")
        
        if let matched = voices.first(where: { voice in
            wantFemale ? (voice.gender == .female) : (voice.gender == .male)
        }) {
            return matched
        }
        
        return voices.first
    }
    func testSpeak() {
        speak(selectedPersonality.testSpeechText)
    }


    
    // MARK: - Hug Count
    func incrementCount(for feeling: HugFeeling) {
        hugCounts[feeling.key, default: 0] += 1
    }
    
    func impactHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Add/Clear Partner
    func addUser(name: String, gender: String) {
        self.name = name
        self.selectedGender = gender
        self.hasName = true
        
        // ✅ ここが「一覧で男/女表示」に必要
        userGenderMap[name] = gender
        
        if !userList.contains(name) {
            userList.append(name)
        }
    }
    
    func clearPartner() {
        name = ""
        selectedGender = "male"
        hasName = false
        partnerGender = ""
    }
    
    // MARK: - Special (single)
    func saveSpecialLine(_ line: String) {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        specialLine = trimmed
    }
    
    func clearSpecialLine() {
        specialLine = ""
        UserDefaults.standard.removeObject(forKey: specialLineKey)
    }
    
    // MARK: - Special (collection)
    private func saveSpecialLines() {
        if let data = try? JSONEncoder().encode(specialLines) {
            UserDefaults.standard.set(data, forKey: specialLinesKey)
        }
    }
    
    private func loadSpecialLines() {
        guard
            let data = UserDefaults.standard.data(forKey: specialLinesKey),
            let items = try? JSONDecoder().decode([SpecialLineItem].self, from: data)
        else { return }
        specialLines = items
    }
    
    func addSpecialLineToCollection(_ line: String) {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // 保存済み1件も更新
        saveSpecialLine(trimmed)
        
        // 集に追加（新しいものが上）
        specialLines.insert(
            SpecialLineItem(id: UUID(), text: trimmed, createdAt: Date()),
            at: 0
        )
    }
    
    func deleteSpecialLines(at offsets: IndexSet) {
        specialLines.remove(atOffsets: offsets)
    }
    
    // MARK: - Optional: remove a user completely (名前+性別)
    func removeUserCompletely(_ user: String) {
        userList.removeAll { $0 == user }
        userGenderMap.removeValue(forKey: user)
        if name == user { clearPartner() }
    }
}

// MARK: - Models
struct SpecialLineItem: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
    let createdAt: Date
}
