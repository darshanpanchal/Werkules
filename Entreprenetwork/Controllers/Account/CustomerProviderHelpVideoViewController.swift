//
//  CustomerProviderHelpVideoViewController.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 10/09/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import AudioToolbox

protocol CustomerProviderHelpDelegate {
    func playerDidFinishWithPlay(isforcustomer:Bool,isForVerifiedProvider:Bool)
}
class CustomerProviderHelpVideoViewController: UIViewController,AVPlayerViewControllerDelegate,UIGestureRecognizerDelegate {


    @IBOutlet weak var videoView: UIView!
    var player: AVPlayer!
    var avpController = AVPlayerViewController()

    var isForCustomer:Bool = true
    var isProviderVerified:Bool = false

    var delegate:CustomerProviderHelpDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
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


        let customerURL = Bundle.main.url(forResource: "customer_help", withExtension:"mp4")
        let providerURL = Bundle.main.url(forResource: "provider_help", withExtension:"mp4")
        self.addChild(avpController)
        if let _ = customerURL,let _ = providerURL{
        //if let url = URL(string:myURL){




                if self.isForCustomer{
                    player = AVPlayer(url: customerURL!)
                }else{
                    player = AVPlayer(url: providerURL!)
                }

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
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
            self.delegate?.playerDidFinishWithPlay(isforcustomer: self.isForCustomer,isForVerifiedProvider:self.isProviderVerified)
        }

    }


    override var shouldAutorotate: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        DispatchQueue.main.async {
            //self.delegate?.playerDidFinishWithPlay(isforcustomer: self.isForCustomer)
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

    }

    //MARK:button click methods
    @IBAction func btnCancelClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.avpController.player?.pause()
            self.delegate?.playerDidFinishWithPlay(isforcustomer: self.isForCustomer,isForVerifiedProvider:self.isProviderVerified)
            self.dismiss(animated: true, completion: nil)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
