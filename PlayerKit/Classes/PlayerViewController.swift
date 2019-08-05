//
//  PlayerViewController.swift
//  PlayerKit
//
//  Created by Jon Andersen on 3/24/19.
//  Copyright © 2019 Andersen. All rights reserved.
//

import AVFoundation
import UIKit

internal let bundle = Bundle(for: PlayerViewController.classForCoder())

public class PlayerViewController: UIViewController {
    @objc var isPlaying: Bool {
        return player.isPlaying == true
    }

    public var tapToPause: Bool = false
    public var showOverlay: Bool = true

    private var isShowingOverlay: Bool = false {
        didSet {
            if isShowingOverlay {
                if showOverlay {
                    UIView.animate(withDuration: 0.3) {
                        self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                    }
                    fullscreenButton.animateShow(true)
                }
                playButton.animateShow(true)
            } else {
                if showOverlay {
                    UIView.animate(withDuration: 0.3) {
                        self.overlayView.backgroundColor = .clear
                    }
                    fullscreenButton.animateShow(false)
                }
                if isPlaying {
                    playButton.animateShow(false)
                }
            }
        }
    }

    @IBOutlet var playerView: PlayerView!

    @IBOutlet var overlayView: UIView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var fullscreenButton: UIButton!

    private let playImage = UIImage(named: "play", in: bundle, compatibleWith: nil)
    private let pauseImage = UIImage(named: "pause", in: bundle, compatibleWith: nil)

    private let maximizeImage = UIImage(named: "maximize", in: bundle, compatibleWith: nil)
    private let minimizeImage = UIImage(named: "minimize", in: bundle, compatibleWith: nil)

    private var playerItem: AVPlayerItem!
    private var playerItemOverlay: OverlayLayer?
    public var player: Player!

    public static func instantiate(playerItem: AVPlayerItem, layers: OverlayLayer?) -> PlayerViewController {
        let viewController = UIStoryboard(name: "PlayerKit", bundle: bundle).instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        viewController.playerItem = playerItem
        viewController.playerItemOverlay = layers
        viewController.player = Player(playerItem: playerItem, autoPlay: false)
        return viewController
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let synchronizedLayer = AVSynchronizedLayer(playerItem: playerItem)
        playerView.playerItemOverlay = playerItemOverlay
        playerView.player = player
        playerView.synchronizedLayer = synchronizedLayer
        playerView.backgroundColor = .clear

        fullscreenButton.isHidden = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        overlayView.addGestureRecognizer(tap)
        overlayView.backgroundColor = .clear

        let tap2 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        playerView.addGestureRecognizer(tap2)

        // Workaround size UIButton sends a unhandled tap event to viewcontroller
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(playButtonOnTap(_:)))
        playButton.addGestureRecognizer(tap3)

        playButton.isEnabled = false
        playButton.showsTouchWhenHighlighted = true

        overlayView.translatesAutoresizingMaskIntoConstraints = true
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.addObserver(self, forKeyPath: #keyPath(Player.isPlaying), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(Player.isReadyToPlay), options: [.new], context: nil)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.removeObserver(self, forKeyPath: #keyPath(Player.isPlaying))
        player.removeObserver(self, forKeyPath: #keyPath(Player.isReadyToPlay))
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayView.frame = playerView.playerLayer.videoRect
    }

    @IBAction func playButtonOnTap(_: Any) {
        playOrPause()
    }

    @IBAction func fullscreenButtonOnTap(_: Any) {
        if UIDevice.current.orientation.isLandscape {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }

    @objc func handleTap(_: UITapGestureRecognizer) {
        if tapToPause {
            player?.pause()
        }
        isShowingOverlay = !isShowingOverlay
    }

    private func playOrPause() {
        if isPlaying {
            player.pause()
        } else {
            if isShowingOverlay {
                isShowingOverlay = false
            }
            player.play()
        }
    }

    func updateFullscreenButton() {
        if UIDevice.current.orientation == .portrait {
            fullscreenButton.setImage(maximizeImage, for: .normal)
        } else {
            fullscreenButton.setImage(minimizeImage, for: .normal)
        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(Player.isPlaying) {
            if isPlaying {
                playButton.setImage(pauseImage, for: .normal)
                playButton.animateShow(false)
            } else {
                playButton.setImage(playImage, for: .normal)
                playButton.animateShow(true)
            }
        } else if keyPath == #keyPath(Player.isReadyToPlay) {
            playButton.isEnabled = true
            view.setNeedsLayout()
        }
    }

    public func apply(transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.5) {
            self.playerView.transform = transform
            self.playerView.frame = self.playerView.superview?.frame ?? .zero
        }
    }
}
