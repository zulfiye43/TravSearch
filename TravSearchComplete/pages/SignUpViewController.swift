//
//  SignUpViewController.swift
//  TravSearchComplete
//


import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var signInButton: UILabel!
    
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.isUserInteractionEnabled = true
                let gestureView = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(gestureView)
         
        // Do any additional setup after loading the view.
        setView()
        progressBar.isHidden = true
    }
    
    @objc func dismissKeyboard(){
           view.endEditing(true)
       }
    
    private func setView(){
        
        let bottomLineName = CALayer()
        bottomLineName.frame = CGRect(x: 0, y: nameTextField.frame.height - 2, width: nameTextField.frame.width, height: 2)
        bottomLineName.backgroundColor = UIColor.placeholderText.cgColor
        nameTextField.borderStyle = UITextField.BorderStyle.none
        nameTextField.layer.addSublayer(bottomLineName)
        
        let bottomLineUsername = CALayer()
        bottomLineUsername.frame = CGRect(x: 0, y: usernameTextField.frame.height - 2, width: usernameTextField.frame.width, height: 2)
        bottomLineUsername.backgroundColor = UIColor.placeholderText.cgColor
        usernameTextField.borderStyle = UITextField.BorderStyle.none
        usernameTextField.layer.addSublayer(bottomLineUsername)
       
        let bottomLineEmail = CALayer()
        bottomLineEmail.frame = CGRect(x: 0, y: emailTextField.frame.height - 2, width: emailTextField.frame.width, height: 2)
        bottomLineEmail.backgroundColor = UIColor.placeholderText.cgColor
        emailTextField.borderStyle = UITextField.BorderStyle.none
        emailTextField.layer.addSublayer(bottomLineEmail)
        
        
        let bottomLinePass = CALayer()
        bottomLinePass.frame = CGRect(x: 0, y: passwordTextField.frame.height - 2, width: passwordTextField.frame.width, height: 2)
        bottomLinePass.backgroundColor = UIColor.placeholderText.cgColor
        passwordTextField.borderStyle = UITextField.BorderStyle.none
        passwordTextField.layer.addSublayer(bottomLinePass)
        
        labelContainer.layer.borderWidth = 1.5
        labelContainer.layer.borderColor = UIColor.systemGreen.cgColor
        labelContainer.layer.cornerRadius = 12.0
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backToLogin))
        let gesRecognizer = UITapGestureRecognizer(target: self, action: #selector(backToLogin))
        backButton.addGestureRecognizer(gestureRecognizer)
        signInButton.addGestureRecognizer(gesRecognizer)
        
    }
    @IBAction func signUp(_ sender: Any) {
        createUser()
    }
    
    // user wird registriert
    func createUser(){
        let nameCharNumber = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
        let usernameCharNumber = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
        // wenn die länge von name und username länger als 6
        if nameCharNumber >= 6 && usernameCharNumber >= 6 && emailTextField.text != "" {
            progressBar.isHidden = false
            progressBar.startAnimating()
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
                // falls registration ohne erfolg
                if error != nil {
                    self.progressBar.isHidden = true
                    self.progressBar.stopAnimating()
                    Util().showAlert(title: "Registration is not Successfully", message: error?.localizedDescription ?? "Error, please try again.",self: self)
                } else {
                    // user wird erstellt
                    let user = User(uuid: Auth.auth().currentUser!.uid,name: self.nameTextField.text!, username: self.usernameTextField.text!, email: self.emailTextField.text!, password: self.passwordTextField.text!, profilePic: "https://jejuhydrofarms.com/wp-content/uploads/2020/05/blank-profile-picture-973460_1280.png")
                    self.addUser(user: user)
                }
            }
        } else {
            // fehleranzeige, wenn die länge von name und username kürzer als 6
            if nameCharNumber < 6 {
                Util().showAlert(title: "Missing Info", message: "Name should be minimum 6 charachters",self: self)
            } else if usernameCharNumber < 6 {
                Util().showAlert(title: "Missing Info", message: "Username should be minimum 6 charachters",self: self)
            } else {
                Util().showAlert(title: "Missing Info", message: "Email Address should be entered",self: self)
            }
            
        }
    }

    // Informationen von Benutzer werden auf Realtime Database hinzugefügt
    func addUser(user: User){
        
        let database = Database.database().reference(withPath: "Users")
        let userData = ["uid": user.uuid,"name": user.name, "username": user.username, "email": user.email, "password": user.password]
        database.child(user.uuid).setValue(userData) { error, databasereference in
            if error != nil {
                self.progressBar.isHidden = true
                self.progressBar.stopAnimating()
                Auth.auth().currentUser?.delete(completion: { error in
                    Util().showAlert(title: "Error!", message: error?.localizedDescription ?? "User is not created, try again!", self: self)
                })
            }else {
                self.progressBar.isHidden = true
                self.progressBar.stopAnimating()
                self.performSegue(withIdentifier: "toTabBar", sender: nil)
            }
        }
    }
    
    @objc func backToLogin(){
        performSegue(withIdentifier: "toLoginVCFromSignUp", sender: nil)
    }
}

