////
////  SpeechManager.swift
////  Skinship
////
////  Created by 田中　よしき on 2025/08/02.
////
//
//import Foundation
//import AVFoundation
//
//class SpeechManager: ObservableObject {
//    let synthesizer = AVSpeechSynthesizer()
//    
//    init() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("Audio session error: \(error.localizedDescription)")
//        }
//    }
//    
//    func speak(_ message: String, isVoiceOn: Bool) {
//        guard isVoiceOn else { return }  // オフなら再生しない
//        
//        let utterance = AVSpeechUtterance(string: message)
//        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
//        utterance.rate = 0.5
//        synthesizer.speak(utterance)
//    }
//}
//
//
