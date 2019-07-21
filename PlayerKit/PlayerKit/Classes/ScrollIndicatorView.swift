//
//  ScrollIndicatorView.swift
//  leapsecond
//
//  Created by Jon Andersen on 6/22/18.
//  Copyright © 2018 Andersen. All rights reserved.
//

import Foundation
import UIKit

class ScrollIndicatorView: UIView {
    fileprivate let indicator: UIView = UIView()
    fileprivate let indicatorBackground: UIView = UIView()

    var indicatorColor: UIColor? {
        didSet {
            indicator.backgroundColor = indicatorColor
        }
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        indicator.backgroundColor = indicatorColor
        indicatorBackground.backgroundColor = UIColor.white
        indicatorBackground.alpha = 0.6
        indicatorBackground.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicatorBackground)
        addSubview(indicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        indicatorBackground.frame = CGRect(x: 0, y: 0, width: 15, height: frame.height)
        indicator.frame = CGRect(x: 5, y: 0, width: 5, height: frame.height)
    }
}
