//
//  PaddingLabel.swift
//  TravSearchComplete
//

import Foundation
import UIKit

// label border deutlicher machen und text darin auffüllen, während Länder in Feed angezeigt werden
@IBDesignable public class PaddingLabel: UILabel {
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    @IBInspectable var leftInset: CGFloat = 0
    @IBInspectable var rightInset: CGFloat = 0
    
    // gibt dem Text eine Auffüllung
    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    // daraus ergibt sich die Größe
    public override var intrinsicContentSize: CGSize{
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
}
