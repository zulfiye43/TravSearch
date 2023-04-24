//
//  CustomTextField.swift
//  TravSearchComplete
//


import UIKit

// bearbeiten die namentextfelder auf der anmelde-, registrierungs- und profilseite
@IBDesignable
class customUITextField: UITextField {
    func setup() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.systemGreen.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

