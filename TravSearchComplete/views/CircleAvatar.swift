//
//  CircleAvatar.swift
//  TravSearchComplete
//


import Foundation

import UIKit

// imageview-kreis erstellen
// wird auf die klasse von imageview erweitert
@IBDesignable class CircleAvatar:UIImageView {
    @IBInspectable var borderColor:UIColor = UIColor.white {
        willSet {
            layer.borderColor = newValue.cgColor
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
    }
}
