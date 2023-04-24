//
//  ViewController.swift
//  TravSearchComplete
//


import UIKit

class ViewController: UIViewController {

    // ViewDidLoad ist die Methode, die aufgerufen wird, sobald die MainView eines ViewControllers geladen wurde
    // damit zugriff auf schaltflächen, beschriftungen usw.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // von der Onboardingseite zu Loginseite gelangen
    @IBAction func goToLoginVC(_ sender: Any) {
        performSegue(withIdentifier: "toLoginVC", sender: nil)
    }
    
    
    
}
