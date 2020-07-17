//
//  PlayerScrollViewController.swift
//  PlayerKit
//
//  Created by Jon Andersen on 7/21/19.
//  Copyright © 2019 Jon Andersen. All rights reserved.
//

import UIKit
import AVFoundation

public class PlayerScrollViewController: UIViewController {

    @IBOutlet weak var thumbnailsView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playerView: UIView!
 
    private let videoThumbnailsViewController = VideoThumbnailsViewController.instantiate()
    public var playerViewController: PlayerViewController!
    private var playerItem: AVPlayerItem!

    public var tapToPause: Bool = false {
        didSet {
            playerViewController.tapToPause = tapToPause
        }
    }
    public var showOverlay: Bool = true {
        didSet {
            playerViewController.showOverlay = showOverlay
        }
    }

    
    public static func instantiate(playerItem: AVPlayerItem, layers: OverlayLayer?) -> PlayerScrollViewController {
        let viewController = UIStoryboard(name: "PlayerKit", bundle: bundle).instantiateViewController(withIdentifier: "PlayerScrollViewController") as! PlayerScrollViewController
        viewController.playerItem = playerItem
        viewController.playerViewController = PlayerViewController.instantiate(playerItem: playerItem, layers: layers)
        return viewController
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        add(playerViewController, to: playerView)
        add(videoThumbnailsViewController, to: thumbnailsView)
        
        videoThumbnailsViewController.delegate = self
        videoThumbnailsViewController.indicatorColor = .blue //TODO config
        
        playerViewController.player.delegate = self
        
        videoThumbnailsViewController.set(asset: playerItem.asset, videoComposition: playerItem.videoComposition)
        

        // Do any additional setup after loading the view.
    }
    
    public func pause(){
        playerViewController?.player.pause()
    }
    
    public func play(){
        playerViewController?.player.play()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerViewController.player.pause()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            // Didn't work
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        do {
			try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .interruptSpokenAudioAndMixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Didn't work
        }
    }
}

extension PlayerScrollViewController: PlayerDelegate, VideoThumbnailsViewControllerDelegate {
    @objc public func moveToTime(_: CGFloat) {}
    
    @objc public func timeChanged(_ time: CGFloat) {
        timeLabel.text = formatTime(time)
        if playerViewController.isPlaying {
            videoThumbnailsViewController.scrollToTime(time: Double(time))
        }
    }
    
    @objc public func playing(_ playing: Bool) {
        videoThumbnailsViewController.view.isUserInteractionEnabled = !playing
    }
    
    @objc public func shouldPlay() -> Bool {
        return true
    }
    
    @objc public func videoTumbnailsViewController(_: VideoThumbnailsViewController, didScrollTo time: Double) {
        timeLabel.text = formatTime(CGFloat(time))
        playerViewController.player.moveTo(CGFloat(time))
    }
    
    private func formatTime(_ time: CGFloat, showMiliSeconds: Bool = true) -> String {
        if time.isNaN {
            return ""
        }
        let actualTime = max(time, 0.0)
        
        let minutes: Int = Int(actualTime.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds: Int = Int(actualTime.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))
        let milliseconds = Int(100 * (actualTime - floor(actualTime)))
        
        if showMiliSeconds {
            return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
