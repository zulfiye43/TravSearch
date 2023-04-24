//
//  Utils.swift
//  TravSearchComplete
//


import Foundation
import UIKit

// Fehlermeldungen und Erfolgsmeldungen werden angezeigt
struct Util{
    func showAlert(title: String, message: String, self: UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

// aktuelle Uhrzeit in Millisekunden abrufen
extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}
