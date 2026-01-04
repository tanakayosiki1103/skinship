import Foundation
import AVFoundation

enum Personality: String, CaseIterable, Identifiable, Hashable {
    case cheerful
    case calm
    case thoughtful
    
    var id: String { rawValue }
    
    var speechRate: Float {
        switch self {
        case .cheerful:   return AVSpeechUtteranceDefaultSpeechRate * 0.9
        case .calm:       return AVSpeechUtteranceDefaultSpeechRate * 0.8
        case .thoughtful: return AVSpeechUtteranceDefaultSpeechRate * 1.07
        }
    }
    
    var pitchMultiplier: Float {
        switch self {
        case .cheerful:   return 1.0
        case .calm:       return 1.3
        case .thoughtful: return 0.85
        }
    }
    
    var testSpeechText: String {
        NSLocalizedString("voice_test_text", comment: "")
    }
}
