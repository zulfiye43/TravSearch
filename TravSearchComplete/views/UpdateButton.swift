//
//  UpdateButton.swift
//  TravSearchComplete
//


import UIKit
// für den uploadButton auf der Upload seite
// button ist sichtbar wenn alles ausgefüllt und ausgeblendet wenn nicht
class UpdateButton: UIButton {
    
    enum ButtonState {
        case normal
        case disabled
    }
    
    private var disabledBackgroundColor: UIColor?
    private var defaultBackgroundColor: UIColor? {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }
    
    //hintergrundfarbe ändern bei isEnabled wert wenn geändert
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                if let color = defaultBackgroundColor {
                    self.backgroundColor = color
                }
            }
            else {
                if let color = disabledBackgroundColor {
                    
                    self.backgroundColor = color
                }
            }
        }
    }
    
    // benutzerdefinierte Funktionen zum Einstellen der Farbe für verschiedene Zustände (state)
    func setBackgroundColor(_ color: UIColor?, for state: ButtonState) {
        switch state {
        case .disabled:
            disabledBackgroundColor = color
        case .normal:
            defaultBackgroundColor = color
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        updateCornerRadius()
    }

    @IBInspectable var rounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }

    func updateCornerRadius() {
        layer.cornerRadius = rounded ? 12 : 0
        layer.masksToBounds = true
    }
}

