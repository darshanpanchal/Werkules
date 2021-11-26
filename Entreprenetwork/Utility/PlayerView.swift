//
//  PlayerView.swift
//  VideoCellDemo
//
//  Created by Hardip Kalola on 21/09/18.
//  Copyright © 2018 digicom. All rights reserved.
//

import UIKit
import AVKit

class PlayerView: UIView {
    
    override class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer : AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player : AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc func play(){
       // player?.isMuted = true
        player?.seek(to: CMTime.zero)
        player?.play()
      //  player?.isMuted = true
    }
    
    
    func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
        if keyPath == "status" {
            print(player!.status)
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
