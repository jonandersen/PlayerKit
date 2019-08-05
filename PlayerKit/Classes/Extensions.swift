//
//  Extensions.swift
//  Scrubber
//
//  Created by Jon Andersen on 6/22/18.
//  Copyright © 2018 Jon Andersen. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func animateShow(_ show: Bool) {
        isHidden = false
        if show {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.alpha = 0
            }, completion: { (_) -> Void in
                self.isHidden = true
            })
        }
    }
}
