//
//  ViewBorder.swift
//  TravSearchComplete
//


import UIKit

// ist für das Button für Location hinzufügen auf der Upload seite
// aktualisieren Rand- und Eckenradius
@IBDesignable class ViewBorder: UIView
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
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.systemGray6.cgColor
        layer.masksToBounds = true
    }

}
