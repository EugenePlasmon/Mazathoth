//
//  AudioPlayerInterface.swift
//  Mazathoth
//
//  Created by Evgeny Kireev on 18/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import Foundation

public enum AudioFileRepresentation {
    case data(Data)
    case contentsOfPath(String)
}

public protocol AudioPlayerInterface: class {
    
    var currentRelativeTime: Double { get set }
    
    func open(_ fileRepresentation: AudioFileRepresentation) throws
    
    func play()
    
    func pause()
    
    func stop()
}
