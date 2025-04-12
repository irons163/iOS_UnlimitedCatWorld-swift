//
//  MyUtils.swift
//  iOS_UnlimitedCatWorld-swift
//
//  Created by Phil on 2025/5/4.
//

import Foundation
import AVFoundation

class MyUtils: NSObject {

    static var backgroundMusicPlayer: AVAudioPlayer?

    static func preparePlayBackgroundMusic(_ filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            NSLog("Could not find file: %@", filename)
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // -1 means loop indefinitely
            backgroundMusicPlayer?.prepareToPlay()
        } catch {
            NSLog("Could not create audio player: %@", error.localizedDescription)
        }
    }

    static func playBackgroundMusic(_ filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            NSLog("Could not find file: %@", filename)
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // -1 means loop indefinitely
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch {
            NSLog("Could not create audio player: %@", error.localizedDescription)
        }
    }

    static func backgroundMusicPlayerStop() {
        backgroundMusicPlayer?.stop()
    }

    static func backgroundMusicPlayerPause() {
        backgroundMusicPlayer?.pause()
    }

    static func backgroundMusicPlayerPlay() {
        backgroundMusicPlayer?.play()
    }

    static func isBackgroundMusicPlayerPlaying() -> Bool {
        return backgroundMusicPlayer?.isPlaying ?? false
    }
}
