//
//  Player.swift
//  leapsecond
//
//  Created by Jon Andersen on 9/12/17.
//  Copyright © 2017 Andersen. All rights reserved.
//

import AVFoundation
import Foundation

public protocol PlayerDelegate: class {
    func moveToTime(_ time: CGFloat)
    func timeChanged(_ time: CGFloat)
    func playing(_ playing: Bool)
    func shouldPlay() -> Bool
}

public class Player: AVPlayer {
    public weak var delegate: PlayerDelegate?

    @objc public dynamic var isPlaying: Bool = false 
    @objc public dynamic var isReadyToPlay: Bool = false

    private var endTime: CGFloat = 0.0
    private var startTime: CGFloat = 0.0
    private var timeObserver: AnyObject?
    private var autoPlay: Bool = false
    private var playerItem: AVPlayerItem?

    override init() {
        super.init()
    }

    @objc public init(playerItem item: AVPlayerItem, autoPlay: Bool = false) {
        super.init(playerItem: item)
        self.playerItem = item
        self.autoPlay = autoPlay
        configurePeriodicTimeObserving()

        item.seekingWaitsForVideoCompositionRendering = true

        NotificationCenter.default.addObserver(self, selector: #selector(pause(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        NotificationCenter.default.addObserver(self, selector: #selector(pause(_:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: item)
        NotificationCenter.default.addObserver(self, selector: #selector(pause(_:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: item)
        playerItem?.addObserver(self, forKeyPath: "status", options: [], context: nil)
    }

    deinit {
        playerItem?.removeObserver(self, forKeyPath: "status", context: nil)
        playerItem = nil
        NotificationCenter.default.removeObserver(self)
        if let timeObserver = self.timeObserver {
            removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }

    @objc func pause(_: Notification) {
        seek(to: CMTimeMakeWithSeconds(Float64(startTime), preferredTimescale: 60), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        delegate?.moveToTime(startTime)
        delegate?.timeChanged(startTime)
        currentItem?.forwardPlaybackEndTime = .invalid
        pause()
    }

    private func configurePeriodicTimeObserving() {
        let mainQueue = DispatchQueue.main
        timeObserver = addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: mainQueue, using: { [weak self] (currentTime) -> Void in
            guard let self = self else {
                return
            }
            let time: CGFloat = CGFloat(CMTimeGetSeconds(currentTime))
            if self.isPlaying{
                self.delegate?.moveToTime(time)
                self.delegate?.timeChanged(time)
            }
        }) as AnyObject?
    }

    public func moveTo(_ start: CGFloat) {
        if let item = self.currentItem, !isPlaying {
            startTime = min(start, CGFloat(CMTimeGetSeconds(item.duration)))
            let timescale = item.duration.timescale
            let seekToTime = CMTimeMakeWithSeconds(Double(startTime), preferredTimescale: timescale)
            if seekToTime == CMTime.invalid {
                return
            }
            var tolerance = CMTimeMakeWithSeconds(0.01, preferredTimescale: timescale)
            tolerance = CMTime.zero
            seek(to: seekToTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
            delegate?.timeChanged(start)
        }
    }

    public func playSection(_ start: CGFloat, end: CGFloat) {
        if isPlaying {
            pause()
            return
        }
        currentItem?.forwardPlaybackEndTime = CMTimeMakeWithSeconds(Float64(end), preferredTimescale: Int32(NSEC_PER_SEC))
        startTime = start
        endTime = end
        play()
    }

    public override func play() {
        if isReadyToPlay, delegate?.shouldPlay() ?? true {
            isPlaying = true
            delegate?.playing(true)
            super.play()
        }
    }

    public override func pause() {
        super.pause()
        isPlaying = false
        delegate?.playing(false)
    }

    @objc
    open override func observeValue(forKeyPath _: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if currentItem?.status == AVPlayerItem.Status.readyToPlay {
            isReadyToPlay = true
            if autoPlay {
                autoPlay = false
                play()
            }
        }
    }
}
