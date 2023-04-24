//
//  RoundedView.swift
//  TravSearchComplete
//

import UIKit

// beim Anzeigen der Posts wird den Ecken einen Radius gegeben
@IBDesignable class RoundedView: UIView
{
    override func layoutSubviews() {
        super.layoutSubviews()

        updateCornerRadius()
    }

    @IBInspectable var rounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }

// die Ansicht wird aktualisiert falls es wahr ist
    func updateCornerRadius() {
        layer.cornerRadius = rounded ? 6 : 0
        layer.masksToBounds = true
    }
}
