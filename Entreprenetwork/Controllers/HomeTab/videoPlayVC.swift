//
//  videoPlayVC.swift
//  SalonAkkad
//
//  Created by IPS on 06/12/18.
//  Copyright © 2018 ips. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import AudioToolbox
//class AVPlayerViewControllerRotatable: AVPlayerViewController {
//
//    override var shouldAutorotate: Bool {
//        return true
//    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
////        if view.bounds == contentOverlayView?.bounds {
////            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
////        }
//
//    }
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
//        return .landscapeLeft
//    }
//
//}
class videoPlayVC: UIViewController,AVPlayerViewControllerDelegate,UIGestureRecognizerDelegate {
    @IBOutlet weak var videoView: UIView!
    var player: AVPlayer!
    var avpController = AVPlayerViewController()
    var strMediaUrl:String = ""

    @IBOutlet weak var lbltitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbltitle.isHidden = false
        self.videoView.backgroundColor = .clear
        self.view.backgroundColor = .black

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        self.autoPlayVideo()
    }
    @objc func autoPlayVideo(){
        let myURL = "\(strMediaUrl)"
        
       
        self.addChild(avpController)
        if let url = URL(string:myURL){
            
                
                DispatchQueue.main.async {
//                    ExternalClass.ShowProgress()
                    self.lbltitle.text = url.absoluteURL.lastPathComponent
                }
                player = AVPlayer(url: url)
                //player.isMuted = false
                avpController.player = player
                avpController.player?.isMuted = false
                avpController.view.frame.size.height = self.videoView.frame.size.height
                avpController.view.frame.size.width = self.videoView.frame.size.width
                avpController.view.isUserInteractionEnabled = true
                self.videoView.addSubview(avpController.view)
                
                NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
                avpController.player?.play()
                avpController.player?.playImmediately(atRate: 1.0)
                avpController.showsPlaybackControls = true
                avpController.exitsFullScreenWhenPlaybackEnds = false
       
    }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "playbackBufferEmpty" {
            DispatchQueue.main.async {
                 ExternalClass.ShowProgress()
            }
            print("Show loader")
            
        } else if keyPath == "playbackLikelyToKeepUp" {
            DispatchQueue.main.async {
                 ExternalClass.HideProgress()
            }
            print("Hide loader")
            
        } else if keyPath == "playbackBufferFull" {
            print("Hide loader")
             DispatchQueue.main.async {
                ExternalClass.HideProgress()
            }
        }
    }
   
    
   
    
    @objc func itemDidFinishPlaying(_ notification: Notification?) {
        /*
        if !isNotAutoPlay{
            player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
          
            DispatchQueue.main.async {
                self.timer.invalidate()
                self.avpController.view.removeFromSuperview()
                self.lbltitle.text = ""
//                VideoPlayerProgressHud.show()
//                self.timer = Timer.scheduledTimer(timeInterval: 5.0, target:self, selector: #selector(videoPlayVC.autoPlayFinishVideo), userInfo: nil, repeats: false)
          }
        }*/
    }
    /*
    @objc func autoPlayFinishVideo(){
        self.lableFlg = 1
        self.lbltitle.isHidden = true
        if self.counter == self.arrayVideoData.count-1{
            self.counter = 0
        }else{
            self.counter+=1
        }
        self.lbltitle.text = self.arrayVideoData[self.counter].given_name
        let myurl  = self.arrayVideoData[self.counter].src
        let url = URL(string:myurl)
        self.player = AVPlayer(url: url!)
        self.avpController.player = self.player
        self.avpController.view.frame.size.height = self.videoView.frame.size.height
        self.avpController.view.frame.size.width = self.videoView.frame.size.width
        self.avpController.view.isUserInteractionEnabled = true
        self.videoView.addSubview(self.avpController.view)
        
        var queue: [AVPlayerItem] = []
        for obj in self.arrayVideoData {
            queue.append(AVPlayerItem(url: NSURL(string: obj.src)! as URL))
        }
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        avpController.player?.play()
        self.bufferingVideo()
    }*/
    /*
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
        DispatchQueue.main.async {
//            VideoPlayerProgressHud.show()
        }
        self.lableFlg = 1
        self.lbltitle.isHidden = true
        avpController.player?.pause()
        avpController.player = nil
        if (sender.direction == .left) {
            if counter == arrayVideoData.count-1{
                counter = 0
            }else{
                counter+=1
            }
            self.lbltitle.text = arrayVideoData[counter].given_name
            let myurl  = arrayVideoData[counter].src
            let url = URL(string:myurl)
            player = AVPlayer(url: url!)
            avpController.player = player
            avpController.view.frame.size.height = self.videoView.frame.size.height
            avpController.view.frame.size.width = self.videoView.frame.size.width
            avpController.view.isUserInteractionEnabled = true
            self.videoView.addSubview(avpController.view)
            
            var queue: [AVPlayerItem] = []
            for obj in arrayVideoData {
                queue.append(AVPlayerItem(url: NSURL(string: obj.src)! as URL))
            }
            NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            avpController.player?.play()
            self.bufferingVideo()
        }
        
        if (sender.direction == .right) {
            if counter <= 0{
                counter = 0
            }else{
                counter-=1
            }
            print(arrayVideoData[counter].src)
            self.lbltitle.text = arrayVideoData[counter].given_name
            let myurl  = arrayVideoData[counter].src
            let url = URL(string:myurl)
            player = AVPlayer(url: url!)
            avpController.player = player
            avpController.view.frame.size.height = self.videoView.frame.size.height
            avpController.view.frame.size.width = self.videoView.frame.size.width
            avpController.view.isUserInteractionEnabled = true
            self.videoView.addSubview(avpController.view)
            
            var queue: [AVPlayerItem] = []
            for obj in arrayVideoData {
                queue.append(AVPlayerItem(url: NSURL(string: obj.src)! as URL))
            }
            NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            avpController.player?.play()
            self.bufferingVideo()
        }
        
    }
    */
    //    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    //        super.viewWillTransition(to: size, with: coordinator)
    //        if (size.width > self.view.frame.size.width) {
    //            print("Landscape")
    //        } else {
    //            print("Portrait")
    //        }
    //    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        AppUtility.lockOrientation(.all)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        AppUtility.lockOrientation(.portrait)
        DispatchQueue.main.async {
//            VideoPlayerProgressHud.hide()
            self.avpController.player?.pause()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func rotated() {
        self.avpController.view.removeFromSuperview()
        if UIDevice.current.orientation.isLandscape {
            self.avpController.view.frame.size.width = self.view.frame.size.height
            self.avpController.view.frame.size.height = self.view.frame.size.width
        } else {
            self.avpController.view.frame.size.height = self.view.frame.size.height
            self.avpController.view.frame.size.width = self.view.frame.size.width
        }
        self.view.addSubview(self.avpController.view)
        avpController.player?.play()
        //        DispatchQueue.main.async {
        //            self.videoView.layoutIfNeeded()
        //        }
    }
    
    //MARK:button click methods
    @IBAction func btnCancelClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.avpController.player?.pause()
            self.dismiss(animated: true, completion: nil)

//            VideoPlayerProgressHud.hide()
        }
       // player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
       // player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
      //  player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
//        AppUtility.lockOrientation(.portrait)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
