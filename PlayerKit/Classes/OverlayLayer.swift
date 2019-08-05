//
//  OverlayLayer.swift
//  PlayerKit
//
//  Created by Jon Andersen on 7/21/19.
//

import Foundation

public protocol OverlayLayer {
    func createLayer(size: CGSize) -> CALayer
}
