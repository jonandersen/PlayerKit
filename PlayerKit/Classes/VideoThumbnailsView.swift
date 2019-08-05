//
//  VideoThumbnailsView.swift
//  leapsecond
//
//  Created by Jon Andersen on 9/9/17.
//  Copyright © 2017 Andersen. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

public protocol VideoThumbnailsViewControllerDelegate: class {
    func videoTumbnailsViewController(_ videoThumbnailsViewController: VideoThumbnailsViewController, didScrollTo time: Double)
}

public class VideoThumbnailsViewController: UIViewController {
    public weak var delegate: VideoThumbnailsViewControllerDelegate?

    fileprivate var asset: AVAsset!
    fileprivate var videoComposition: AVVideoComposition?

    fileprivate var duration: Float64 = 0.0
    fileprivate var currentTime: Double = 0.0
    private var isRotating: Bool = false

    @IBOutlet var scrollIndicator: ScrollIndicatorView!

    public var indicatorColor: UIColor? {
        didSet {
            scrollIndicator.indicatorColor = indicatorColor
        }
    }

    @IBOutlet var collectionView: UICollectionView!

    fileprivate lazy var border: UIView = {
        let view = UIView()
//        view.backgroundColor = Asset.Colors.darkBackground.color
        return view
    }()

    fileprivate let imageQueue = DispatchQueue.global(qos: .userInitiated)

    fileprivate var generator: AVAssetImageGenerator?

    public static func instantiate() -> VideoThumbnailsViewController {
        let viewController = UIStoryboard(name: "PlayerKit", bundle: Bundle(for: VideoThumbnailsViewController.classForCoder())).instantiateViewController(withIdentifier: "VideoThumbnailsViewController") as! VideoThumbnailsViewController
        return viewController
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MarginCell")
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        view.addSubview(border)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
        isRotating = true
        let time = currentTime
        coordinator.animate(alongsideTransition: { _ in
        }, completion: { _ in
            self.isRotating = false
            self.collectionView.reloadData()

            // Wait for layout to update before scrolling
            DispatchQueue.main.async {
                self.scrollToTime(time: time)
            }
        })
    }

    public func set(asset: AVAsset, videoComposition: AVVideoComposition?) {
        duration = CMTimeGetSeconds(asset.duration)
        self.asset = asset
        self.videoComposition = videoComposition
        generator = AVAssetImageGenerator(asset: asset)
        generator?.videoComposition = videoComposition
        generator?.appliesPreferredTrackTransform = true
        collectionView.reloadData()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        border.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 1)
    }

    public func scrollToTime(time: Double) {
        currentTime = time
        collectionView.delegate = nil
        collectionView.contentOffset.x = (collectionView.contentSize.width - view.frame.width) * CGFloat(currentTime / max(duration, 1.0))
        collectionView.delegate = self
    }

    fileprivate func generateVideoThumb(second: Double, completionHandler: @escaping (UIImage?) -> Void) {
        let time = NSValue(time: CMTimeMakeWithSeconds(second + 0.1, preferredTimescale: 600))
        generator?.generateCGImagesAsynchronously(forTimes: [time], completionHandler: { _, ref, _, _, _ in
            if let cgImage = ref {
                completionHandler(UIImage(cgImage: cgImage))
            } else {
                completionHandler(nil)
            }
        })
    }
}

extension VideoThumbnailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    public func scrollViewDidScroll(_: UIScrollView) {
        if isRotating {
            return
        }
        let percentage = collectionView.contentOffset.x / max(collectionView.contentSize.width - view.frame.width, 1.0)
        currentTime = duration * Double(percentage)
        delegate?.videoTumbnailsViewController(self, didScrollTo: currentTime)
    }

    public func numberOfSections(in _: UICollectionView) -> Int {
        return 3
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return Int(duration)
        } else {
            return 1
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCollectionViewCell", for: indexPath) as! ThumbnailCollectionViewCell
            cell.tag = indexPath.item
            cell.imageView.contentMode = .scaleAspectFill
            generateVideoThumb(second: Double(indexPath.item)) { image in
                DispatchQueue.main.async {
                    if cell.tag == indexPath.item {
                        cell.imageView.image = image
                    }
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarginCell", for: indexPath)
            cell.backgroundColor = .clear
            return cell
        }
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 {
            return CGSize(width: view.frame.height, height: view.frame.height)
        } else {
            return CGSize(width: view.frame.width / 2, height: view.frame.height)
        }
    }
}
