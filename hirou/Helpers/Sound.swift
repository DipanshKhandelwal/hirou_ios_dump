//
//  Sound.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 21/02/21.
//  Copyright © 2021 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import AVFoundation

class Sound {
    class func playInteractionSound() {
        let systemSoundID: SystemSoundID = 1104;
        AudioServicesPlaySystemSound(systemSoundID)
    }
}
