//
//  ViewController.swift
//  PlayerKit-Demo
//
//  Created by Jon Andersen on 7/21/19.
//  Copyright © 2019 Norse Ventures LLC. All rights reserved.
//

import UIKit
import PlayerKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    var playerViewController: PlayerScrollViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
//        let url = Bundle.main.url(forResource: "IMG_8039", withExtension: "MOV")!
        let asset = AVURLAsset(url: url)
        playerViewController = PlayerScrollViewController.instantiate(playerItem: AVPlayerItem(asset: asset), layers: nil)
        playerViewController.showOverlay = false
        playerViewController.tapToPause = true
        add(playerViewController, to: view)
        view.bringSubviewToFront(button)
    }
    
    @IBAction func playSection(_ sender: Any) {
        playerViewController.playerViewController.player.playSection(0.33, end: 1.33)
    }
    
}



extension UIViewController {
    func add(_ child: UIViewController, to view: UIView) {
        addChild(child)
        view.addSubview(child.view)
        constrainViewEqual(holderView: view, view: child.view)
        child.didMove(toParent: self)
    }
    
    private func constrainViewEqual(holderView: UIView, view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let pinTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                        toItem: holderView, attribute: .top, multiplier: 1.0, constant: 0)
        let pinBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
                                           toItem: holderView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let pinLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
                                         toItem: holderView, attribute: .left, multiplier: 1.0, constant: 0)
        let pinRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
                                          toItem: holderView, attribute: .right, multiplier: 1.0, constant: 0)
        
        holderView.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
    }
}
