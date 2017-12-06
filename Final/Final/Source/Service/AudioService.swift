//
//  AudioService.swift
//  Final
//
//  Created by Zippo Xie on 12/5/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import Foundation
import AVFoundation

var appHasMicAccess = false

enum AudioStatus: Int, CustomStringConvertible {
    case Stopped = 0,
    Playing,
    Recording
    
    var audioName: String {
        let audioNames = [
            "Audio: Stopped",
            "Audio:Playing",
            "Audio:Recording"]
        return audioNames[rawValue]
    }
    
    var description: String {
        return audioName
    }
}

class AudioService {
    
    var shared : AudioService {
        return AudioService()
    }
    private init(){
    }
}
