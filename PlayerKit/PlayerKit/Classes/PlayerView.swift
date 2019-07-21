//
//  photos.swift
//  leapsecond
//
//  Created by Jon Andersen on 9/12/17.
//  Copyright © 2017 Andersen. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

public class PlayerView: UIView {
    public var player: Player? {
        get {
            return playerLayer.player as? Player
        }
        set {
            player?.removeObserver(self, forKeyPath: #keyPath(Player.isPlaying))
            player?.removeObserver(self, forKeyPath: #keyPath(Player.isReadyToPlay))

            playerLayer.player = newValue

            player?.addObserver(self, forKeyPath: #keyPath(Player.isPlaying), options: [.new], context: nil)
            player?.addObserver(self, forKeyPath: #keyPath(Player.isReadyToPlay), options: [.new], context: nil)
        }
    }

    public var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    public var synchronizedLayer: AVSynchronizedLayer? {
        willSet {
            synchronizedLayer?.removeFromSuperlayer()
        }
        didSet {
            if let synchronizedLayer = synchronizedLayer {
                layer.insertSublayer(synchronizedLayer, above: layer)
                synchronizedLayer.frame = playerLayer.videoRect
            }
        }
    }

    public var playerItemOverlay: OverlayLayer?
    private var currentPlayerItemOverlayLayer: CALayer? {
        willSet {
            currentPlayerItemOverlayLayer?.removeFromSuperlayer()
        }
        didSet {
            if let currentPlayerItemOverlayLayer = currentPlayerItemOverlayLayer {
                synchronizedLayer?.addSublayer(currentPlayerItemOverlayLayer)
                currentPlayerItemOverlayLayer.frame = CGRect(origin: .zero, size: playerLayer.videoRect.size)
            }
        }
    }

    func recreateLayers() {
        guard let playerItemOverlay = playerItemOverlay else {
            return
        }
        if currentPlayerItemOverlayLayer?.frame == playerLayer.videoRect {
            return
        }
        let newPlayerItemOverlayLayer = playerItemOverlay.createLayer(size: playerLayer.videoRect.size)
        currentPlayerItemOverlayLayer = newPlayerItemOverlayLayer
    }

    public override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(Player.isReadyToPlay) {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            synchronizedLayer?.frame = playerLayer.videoRect
            recreateLayers()
            CATransaction.commit()
        }
    }

    deinit {
        player = nil
    }

    // Override UIView property
    public override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard let synchronizedLayer = synchronizedLayer else {
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        synchronizedLayer.frame = playerLayer.videoRect
        recreateLayers()
        CATransaction.commit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        playerLayer.transform = CATransform3DMakeRotation(0.0, 0, 0.0, 1.0)
//        playerLayer.videoGravity = .resizeAspect
    }
}
