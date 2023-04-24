//
//  ProfileViewController.swift
//  TravSearchComplete
//


import UIKit
import Firebase
import SDWebImage
 
// die profilseite des users
class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var profileImageView: CircleAvatar!
    @IBOutlet weak var nameTextField: customUITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var savedButton: UIButton!
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var likedPostsButton: UIButton!
    @IBOutlet weak var bookmarksButton: UIButton!
    
    let imagePickerController = UIImagePickerController()
    
    var isShowingPost = true
    
    var posts : [Post] = []
    
    let currentUser = Auth.auth().currentUser!.uid
    var selectedPP = UIImage()

    var savedPosts : [Post] = []
    var userProfilePic = ""
    var selectedPost : Post?
    var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.isUserInteractionEnabled = true
                let gestureView = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(gestureView)
        
       
        okButton.isHidden = true
        nameTextField.isEnabled = false
        nameTextField.layer.borderColor = UIColor.white.cgColor
        
        // nicht anklickbare ansichten eine klickfunktion hinzufügen, hier: profileImageView
        profileImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        profileImageView.addGestureRecognizer(gestureRecognizer)
        
        // für die ansicht
        topView.clipsToBounds = true
        topView.layer.cornerRadius = 25
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        // jeweilige funktionen werden angezeigt auf der view
        collectionView.delegate = self
        collectionView.dataSource = self
        setView()
        getPosts()
        getSavedPosts()
        
        savedButton.isHidden = true
        progressBar.isHidden = true
    }
    // damit nach der Eingabe Keyboard weggeht
    @objc func dismissKeyboard(){
            view.endEditing(true)
        }
    
    // verbindung zu realtime database
    func setView(){
        let database = Database.database().reference(withPath: "Users")
        database.child(currentUser).observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            // informationen für user
            let username = value?["username"] as? String ?? ""
            let name = value?["name"] as? String ?? ""
            let pp = value?["profilePic"] as? String ?? ""
            
            self.nameTextField.text = name
            self.usernameLabel.text = "@" + username
            // profilbild wenn pp gleich nil und leer ist
            if pp != nil && pp != "" {
                self.profileImageView.sd_setImage(with: URL(string: pp))
                self.userProfilePic = pp
            }
        }
    }
    // alle gespeicherten Beiträge werden abgerufen
    // verbindung zu firebase realtime database wird hergestellt
    // Dictionary-Daten werden in ein savedPosts-Array konvertiert und gespeichert
    func getSavedPosts(){
        Database.database().reference().child("SavedPosts").child(Auth.auth().currentUser!.uid).observe(.value) { snapshot in
            self.savedPosts.removeAll()
            for i in snapshot.children{
                if let childSnapshot = i as? DataSnapshot{
                    if let value = childSnapshot.value as? NSDictionary{
                        for j in value{
                            if let post = j.value as? NSDictionary {
                                let post = Post(userID: post["userID"] as? String ?? "", downloadUrl: post["downloadUrl"] as? String ?? "", caption: post["caption"] as? String ?? "", country: post["country"] as? String ?? "", category: post["category"] as? String ?? "", likeCount: post["likeCount"] as? Int ?? 0, note: post["note"] as? String ?? "", isImage: post["isImage"] as? Bool ?? true, key: post["key"] as? String ?? "", time: post["time"] as? Int64 ?? 1600000000, thumbnail: post["thumbnail"] as? String ?? "", senderName: post["senderName"] as? String ?? "",senderProfilePic: post["senderProfilePic"] as? String ?? "")
                                self.savedPosts.append(post)
                            }
                        }
                    }
                }
            }
            self.collectionView.reloadData()
        }
    }
    // alle Beiträge werden aufgenommen
    // verbindung mit Firebase realtime database wird hergestellt
    // Dictionary-Daten werden in ein Posts-Array konvertiert und gespeichert
    func getPosts(){
        let database = Database.database().reference(withPath: "Posts")
        database.child(currentUser).queryOrdered(byChild: "time").observe(.value) { snapshot in
            self.posts.removeAll()
            for i in snapshot.children {
                if let childSnapshot = i as? DataSnapshot {
                    if let value = childSnapshot.value as? NSDictionary{
                        let post = Post(userID: value["userID"] as? String ?? "", downloadUrl: value["downloadUrl"] as? String ?? "", caption: value["caption"] as? String ?? "", country: value["country"] as? String ?? "", category: value["category"] as? String ?? "", likeCount: value["likeCount"] as? Int ?? 0, note: value["note"] as? String ?? "", isImage: value["isImage"] as? Bool ?? true, key: value["key"] as? String ?? "", time: value["time"] as? Int64 ?? 1600000000, thumbnail: value["thumbnail"] as? String ?? "", senderName: value["senderName"] as? String ?? "",senderProfilePic: value["senderProfilePic"] as? String ?? "")
                        
                        self.posts.append(post)
                    }
                }
            }
            
            self.posts.reverse()
            self.collectionView.reloadData()
        }
        
    }
    
    
    // zeigt, wie viele Elemente in den Abschnitten in der collectionView angezeigt werden, hier: beiträge und gespeicherte beiträge
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isShowingPost {
            return posts.count
        }else {
            return savedPosts.count
        }
    }
    
    // zelle für die profile anisicht
    // wird mit ProfileCollectioncell verbunden
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionCell", for: indexPath) as! ProfileCollectionCell
        
      //  Da sich die Methode der Schaltfläche in einer anderen Klasse befindet, ist es notwendig, das self der Schaltfläche zu erfassen und nicht zu übersehen
        cell.deleteButtonAction = { [unowned self] in
            // einen beitrag löschen
            let countryData = posts[indexPath.row].country
            let alert = UIAlertController(title: "Delete Post", message: "Sure, you are deleting post", preferredStyle: UIAlertController.Style.alert)
            let okButtonAlert = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { okbuttonalert in
      
                // wenn man einen Beitrag löscht, wird auch das Land gelöscht, also es wird kontrolliert
                // aber nur der Beitrag der gelöscht werden muss und nicht alle beiträge im land
                // das ganze beitrag gelöscht
                do{
                    var countryList = [String]()
                    Database.database().reference().child("AllPosts").child(posts[indexPath.row].key).removeValue { error, referece in
                        if error == nil {
                            Database.database().reference().child("AllPosts").observeSingleEvent(of: .value) { snapshot in
                                for i in snapshot.children{
                                    if let childSnapshot = i as? DataSnapshot {
                                        if let value = childSnapshot.value as? NSDictionary{
                                            let country = value["country"] as? String ?? ""
                                            countryList.append(country)
                                        
                                        }
                                    }
                                }
                                // hier wird nur das land gelöscht
                                if countryList.contains(countryData) == false {
                                    Database.database().reference().child("Countries").child(countryData).removeValue()
                                }
                            }
                        }
                    }
            
                    // wenn der beitrag schon geliket wurde, werden auch andere informationen gelöscht zb wenn ein anderer benutzer es geliket hat oder gespeichert hat
                    // es wird in diesen jeweiligen childs gelöscht
                    Database.database().reference().child("Posts").child(Auth.auth().currentUser!.uid).child(posts[indexPath.row].key).removeValue()
                    Database.database().reference().child("SavedPosts").child(Auth.auth().currentUser!.uid).child(posts[indexPath.row].userID).child(posts[indexPath.row].key).removeValue()
                    Database.database().reference().child("LikedPosts").child(Auth.auth().currentUser!.uid).child(posts[indexPath.row].userID).child(posts[indexPath.row].key).removeValue()
                    Database.database().reference().child("Notifications").child(Auth.auth().currentUser!.uid).child(posts[indexPath.row].key).removeValue()
                } catch let error {
                    Util().showAlert(title: "Deleting is not Successful", message: error.localizedDescription ?? "Deleting is not Successful",self: self)
                }
            }
            // "beitrag löschen" abbrechen
            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { okbutton in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okButtonAlert)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
        }
 
        // den Beitrag als "gespeichert" löschen, wenn man es zurückziehen möchte
        cell.saveButtonAction = { [unowned self] in
            Database.database().reference().child("SavedPosts").child(Auth.auth().currentUser!.uid).child(savedPosts[indexPath.row].userID).child(savedPosts[indexPath.row].key).removeValue()
        }

        // ob der benutzer seine beiträge guckt
        if isShowingPost {
            // image
            if posts[indexPath.row].isImage {
                cell.postView.isHidden = false
                cell.likedView.isHidden = true
                cell.imageView.sd_setImage(with: URL(string: posts[indexPath.row].downloadUrl))
                cell.postCountryLabel.text = posts[indexPath.row].country
                cell.postLabel.text = posts[indexPath.row].category
                cell.postLikeCount.text = String(posts[indexPath.row].likeCount)
                cell.playButton.isHidden = true
             // video
            } else {
                cell.postView.isHidden = false
                cell.likedView.isHidden = true
                cell.imageView.sd_setImage(with: URL(string: posts[indexPath.row].thumbnail))
                cell.postCountryLabel.text = posts[indexPath.row].country
                cell.postLabel.text = posts[indexPath.row].category
                cell.postLikeCount.text = String(posts[indexPath.row].likeCount)
                cell.playButton.isHidden = false
            }
            
            // oder die gespeicherten Beiträge
        }else {
            cell.likedView.isHidden = false
            cell.postView.isHidden = true
            cell.savedProfileImageView.sd_setImage(with: URL(string: savedPosts[indexPath.row].senderProfilePic), completed: nil)
            let timeData = Int64(savedPosts[indexPath.row].time)
            let date = Date(timeIntervalSince1970: Double(timeData) / 1000)
            cell.savedTimeLabel.text = date.timeAgoDisplay()
            Database.database().reference().child("Users").child(savedPosts[indexPath.row].userID).child("username").observeSingleEvent(of: .value) { snapshot in
                if let username = snapshot.value as? String{
                    cell.savedUsernameLabel.text = "@\(username)"
                }
            } // wenn es ein Bild ist dann kein playbutton, wenn video mit playbutton
            if savedPosts[indexPath.row].isImage {
                cell.playButton.isHidden = true
                cell.imageView.sd_setImage(with: URL(string: self.savedPosts[indexPath.row].downloadUrl), completed: nil)
            } else {
                cell.playButton.isHidden = false
                cell.imageView.sd_setImage(with: URL(string: self.savedPosts[indexPath.row].thumbnail), completed: nil)
            }
        }

        // wenn man auf dem Beitrag auf das Profilbild geht, geht man auf die Profilseite des users
        cell.savedProfileImageAction = {
            self.userID = self.savedPosts[indexPath.row].userID
            print(self.userID)
            self.goToUserProfile()
        }
        
        return cell
    }
    // geht zu userprofile
    func goToUserProfile(){
        if userID != "" {
            performSegue(withIdentifier: "goToUserProfileFromProfile", sender: nil)
        }
        
        
    }
    // mit dem ausgewählten post oder ausgewählte gespeicherte post, wenn man es auswählt/klickt geht man auf die detail seite es wird detailliert angezeigt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isShowingPost {
            selectedPost = posts[indexPath.row]
        } else{
            selectedPost = savedPosts[indexPath.row]
        }
        
        performSegue(withIdentifier: "toDetailFromProfile", sender: nil)
    }
    
    // destinationVC stellt die Seite dar, die man von der Seite aus aufgerufen hat, auf der user sich befindet
    // zugriff auf alle Funktionen und Variablen auf dieser Seite
    // ausgewählten Beitrag an die userprofileseite senden
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier == "toDetailFromProfile"){
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.post = selectedPost
        } else if segue.identifier == "goToUserProfileFromProfile" {
            let destinationVC = segue.destination as! UserProfileViewController
            destinationVC.userID = self.userID
        }
    }
    
    // profilbild auswählen
    @objc func selectProfileImage(){
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController, animated: true)
    }

    // der benutzer wählt ein foto aus der galerie und setzt das als profilbild fest
    // in saveProfileImage wird die verbindung zu database hergestellt
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.image = info[.originalImage] as? UIImage
        selectedPP = (info[.originalImage] as? UIImage)!
        self.dismiss(animated: true, completion: nil)
        
        self.savedButton.isHidden = false
    }
    
    // ausloggen
    @IBAction func logOut(_ sender: Any) {
        
        let alert = UIAlertController(title: "Log Out", message: "Sure, you are quit now", preferredStyle: UIAlertController.Style.alert)
        let okButtonAlert = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { okbuttonalert in
            do{
                //nutzer abmelden
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "toLoginVCFromTabBar", sender: nil)
            }catch {
                Util().showAlert(title: "Sign Out is not Successfully", message: "Please Try Later!",self: self)
            }
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { okbutton in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okButtonAlert)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    // namen bearbeiten
    @IBAction func editName(_ sender: Any) {
        editButton.isHidden = true
        okButton.isHidden = false
        nameTextField.isEnabled = true
    }
    
    // wenn name eingetragen ist
    // verbindung mit Firebase realtime database wird hergestellt
    @IBAction func doneName(_ sender: Any) {
        
        let name = nameTextField.text
        
        let database = Database.database().reference().child("Users").child(currentUser).child("name")
        database.setValue(name) { error, reference in
            if error == nil{
                self.okButton.isHidden = true
                self.editButton.isHidden = false
                self.nameTextField.isEnabled = false
                self.nameTextField.layer.borderColor = UIColor.white.cgColor
            } else {
                Util().showAlert(title: "Error", message: error?.localizedDescription ?? "Named changed error", self: self)
                self.okButton.isHidden = true
                self.editButton.isHidden = false
                self.nameTextField.isEnabled = false
                self.nameTextField.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
    
    // wenn auf kamera ausgewählt wird, wird es ausgefüllt "camera.fill" in dark green
    @IBAction func showPosts(_ sender: Any) {
        postsButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        postsButton.tintColor = .systemGreen
        bookmarksButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        bookmarksButton.tintColor = .darkGray
        isShowingPost = true
        collectionView.reloadData()
    }
    
    // wenn auf bookmark ausgewählt wird, wird es ausgefüllt "bookmark.fill" in dark green
    @IBAction func showBookmarkPosts(_ sender: Any) {
        
        postsButton.setImage(UIImage(systemName: "camera"), for: .normal)
        postsButton.tintColor = .darkGray
        bookmarksButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        bookmarksButton.tintColor = .systemGreen
        
        isShowingPost = false
        collectionView.reloadData()
    }
    
    // wenn man profilbild geändert hat, um es zu speichern
    // in database gepspeichert
    // ist die action für savebutton
    @IBAction func saveProfileImage(_ sender: Any) {
        savedButton.isEnabled = false
        progressBar.startAnimating()
        progressBar.isHidden = false
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("media").child(self.currentUser).child("profilePic")
        // die qualität des  profilbilds wird reduziert, damit es schneller geht beim Hochladen des Profilbildes, mit putdata hochgeladen
        if let data = selectedPP.jpegData(compressionQuality: 0.25){
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { storagemetadata, error in
                if error != nil {
                    Util().showAlert(title: "Error", message: error?.localizedDescription ?? "Uploading Error", self: self)
                    self.progressBar.isHidden = true
                    self.progressBar.stopAnimating()
                    self.savedButton.isEnabled = true
                } else{
                    // die url wird in database gespeichert
                    // von dort wird es immer Zugreifbar
                    imageReference.downloadURL { url, error in
                        if error == nil {
                            if let imageUrl = url?.absoluteString{
                                let database = Database.database().reference().child("Users").child(self.currentUser).child("profilePic")
                                database.setValue(imageUrl) { error, reference in
                                    if error == nil {
                                        self.progressBar.isHidden = true
                                        self.progressBar.stopAnimating()
                                        self.savedButton.isEnabled = true
                                        self.savedButton.isHidden = true
                                    } else{
                                        self.progressBar.isHidden = true
                                        self.progressBar.stopAnimating()
                                        self.savedButton.isEnabled = true
                                        Util().showAlert(title: "Error", message: error?.localizedDescription ?? "Profile Pic Uploading Error", self: self)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

