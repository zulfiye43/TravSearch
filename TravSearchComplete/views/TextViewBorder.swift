//
//  TextViewBorder.swift
//  TravSearchComplete
//


import UIKit

// für die Beschriftung textfield in Uploadseiten
// aktualisieren textfeldrand und eckenradius
@IBDesignable class TextViewBorder: UITextView
{

    override func layoutSubviews() {
        super.layoutSubviews()

        updateCornerRadius()
        updateBorder()
    }

    @IBInspectable var rounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }

    func updateCornerRadius() {
        layer.cornerRadius = rounded ? 6 : 0
        layer.masksToBounds = true
    }
    
    func updateBorder(){
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray6.cgColor
        layer.masksToBounds = true
    }

}
