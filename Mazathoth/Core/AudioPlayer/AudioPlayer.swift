//
//  AudioPlayer.swift
//  Mazathoth
//
//  Created by Evgeny Kireev on 18/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import Foundation
import AVFoundation

public final class AudioPlayer {
    
    // MARK: - Singleton
    
    public static let shared = AudioPlayer()
    
    // MARK: - Private properties
    
    private var player: AVAudioPlayer?
}

// MARK: - AudioPlayerInterface
extension AudioPlayer: AudioPlayerInterface {
    
    public func open(_ fileRepresentation: AudioFileRepresentation) throws {
        switch fileRepresentation {
        case .data(let data):
            self.player = try AVAudioPlayer(data: data)
        case .contentsOfPath(let path):
            self.player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        }
    }
    
    public func play() {
        self.player?.play()
    }
    
    public func pause() {
        self.player?.pause()
    }
    
    public func stop() {
        self.player?.stop()
    }
    
    public var currentRelativeTime: Double {
        get { return self.player >>- { $0.currentTime / $0.duration } ?? 0.0 }
        set { self.player >>- { $0.currentTime = $0.duration * newValue } }
    }
}
