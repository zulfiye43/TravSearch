//
//  LoginViewController.swift
//  TravSearchComplete
//


import UIKit
import Firebase

// Loginseite

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var labelContainer: UIView!
    
    @IBOutlet weak var backButton: UIImageView!
    
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        progressBar.isHidden = true
        
        view.isUserInteractionEnabled = true
                let gestureView = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(gestureView)
        
    }
    
    @objc func dismissKeyboard(){
           view.endEditing(true)
       }
    
    private func setView(){
        
        // für email textfield
        emailTextField.frame.size.height = 40
        // textfield-unterstreichung
        let bottomLineEmail = CALayer()
        bottomLineEmail.frame = CGRect(x: 0, y: emailTextField.frame.height - 2, width: emailTextField.frame.width, height: 2)
        bottomLineEmail.backgroundColor = UIColor.placeholderText.cgColor
        emailTextField.borderStyle = UITextField.BorderStyle.none
        emailTextField.layer.addSublayer(bottomLineEmail)
        
        // für passwort textfield
        let bottomLinePass = CALayer()
        bottomLinePass.frame = CGRect(x: 0, y: passwordTextField.frame.height - 2, width: passwordTextField.frame.width, height: 2)
        bottomLinePass.backgroundColor = UIColor.placeholderText.cgColor
        passwordTextField.borderStyle = UITextField.BorderStyle.none
        passwordTextField.layer.addSublayer(bottomLinePass)
        
        
        labelContainer.layer.borderWidth = 1.5
        labelContainer.layer.borderColor = UIColor.systemGreen.cgColor
        labelContainer.layer.cornerRadius = 12.0
        
        // bei nicht anklickbaren ansichten eine klickfunktion hinzufügen
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backToOnboard))
        backButton.addGestureRecognizer(gestureRecognizer)
        
    }
    // email & passwort werden überprüft und startet anmeldevorgang
    @IBAction func signIn(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            signIn(email: emailTextField.text!, password: passwordTextField.text!)
        }
    }
    // aktivitätsanzeige wenn anmeldevorgang beginnt
    func signIn(email: String, password: String){
        progressBar.isHidden = false
        progressBar.startAnimating()
        // email & passwort wird an auth gesendet, welches sich in der Firebase-Bibliothek befindet
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if error != nil {
                self.progressBar.isHidden = true
                self.progressBar.stopAnimating()
                // mögliche Fehler anzeigen
                Util().showAlert(title: "Login is not Successfully", message: error?.localizedDescription ?? "Login error, please try again.",self: self)
            } else {
                // aktivitätsanzeige wird unsichtbar falls es zu keinem fehler kommt
                self.progressBar.isHidden = true
                self.progressBar.stopAnimating()
                self.performSegue(withIdentifier: "toTabBarFromLogin", sender: nil)
            }
        }
    }
    // auf die onbaordingseite gehen
    @objc func backToOnboard(){
        performSegue(withIdentifier: "toOnboardVC", sender: nil)
    }
    
    // auf die signupseite gehen
    @IBAction func goToSignUp(_ sender: Any) {
        performSegue(withIdentifier: "toSignUpVC", sender: nil)
    }
    
    // wenn das passwort vergessen wurde
    @IBAction func forgotPassword(_ sender: Any) {
        let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
            forgotPasswordAlert.addTextField { (textField) in
                textField.placeholder = "Enter email address"
            }
            forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in let resetEmail = forgotPasswordAlert.textFields?.first?.text
                // wird in die Firebase Bibliothek gesendet
                Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in if error != nil{
                    // wenn sich der benutzer nicht erfolgreich anmelden konnte
                        let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                        resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetFailedAlert, animated: true, completion: nil)
                    }else {
                        //reset von email hat geklappt
                        let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                        resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetEmailSentAlert, animated: true, completion: nil)
                    }
                })
            }))
           
        self.present(forgotPasswordAlert, animated: true, completion: nil)
    }
}
