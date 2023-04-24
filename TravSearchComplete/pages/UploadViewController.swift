//
//  UploadViewController.swift
//  TravSearchComplete
//


import UIKit
import Firebase
import AVFoundation
import SDWebImage

// auf Uploadview kann der nutzer fotos/videos hochladen, eigenen beiträge hochladen
class UploadViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionTextView: TextViewBorder!
    
    @IBOutlet weak var uploadButton: UpdateButton!
    @IBOutlet weak var photoView: RoundedView!
    
    @IBOutlet weak var videoView: RoundedView!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var locationView: ViewBorder!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicImage: CircleAvatar!
    @IBOutlet weak var progressBarUpload: UIActivityIndicatorView!
    
    var uid = ""
    
    var pickerData = [String]()
    let imagePickerController = UIImagePickerController()
    var videoURL: NSURL?
    
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 5
    
    var selectedRow = 0
    var selectedCountry : String = ""
    var selectedCategory : String = ""
    var isImage = false
    var thumbnail = UIImage()
    
    var senderName = ""
    var senderProfilePic = ""
    
    var videoUrl : NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
// nutzer kann kategorie aussuchen
        pickerData = ["Landscape","Historical","Eat&Drink","Building","People","Animals"]
        
        progressBarUpload.isHidden = true
        // untertitel für beitrag
        captionTextView.delegate = self
        captionTextView.text = "Add a caption..."
        captionTextView.textColor = UIColor.lightGray
        captionTextView.contentInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        
        view.isUserInteractionEnabled = true
                let gestureView = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(gestureView)
        // nicht anklickbare ansichten eine klickfunktion hinzufügen, hier: selectimage
        photoView.isUserInteractionEnabled = true
        let gestureRecognizerPhoto = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        photoView.addGestureRecognizer(gestureRecognizerPhoto)
        
        locationView.isUserInteractionEnabled = true
        let gestureRecognizerLocation = UITapGestureRecognizer(target: self, action: #selector(selectLocation))
        locationView.addGestureRecognizer(gestureRecognizerLocation)
        
        let gestureRecognizerVideo = UITapGestureRecognizer(target: self, action: #selector(selectVideo))
        videoView.addGestureRecognizer(gestureRecognizerVideo)
        
        uploadButton.setBackgroundColor(.systemGreen, for: .normal)
        uploadButton.setBackgroundColor(UIColor.systemGreen.withAlphaComponent(0.3), for: .disabled)
   
        
        uploadButton.isEnabled = false
        
        // verbindung zu realtime database
        let database = Database.database().reference(withPath: "Users")
        database.child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            // informationen für user
            let username = value?["username"] as? String ?? ""
            let name = value?["name"] as? String ?? ""
            let pp = value?["profilePic"] as? String ?? ""
            self.uid = Auth.auth().currentUser!.uid
            self.nameLabel.text = name
            self.usernameLabel.text = "@" + username
            self.senderName = name
            // profilbild wenn pp gleich nil und leer ist
            if pp != nil && pp != "" {
                self.profilePicImage.sd_setImage(with: URL(string: pp))
                self.senderProfilePic = pp
            }
        }
        
        
    }
    // damit keyboard verschwindet nach dem eintippen
    @objc func dismissKeyboard(){
            view.endEditing(true)
        }
    
    // verarbeitet das ausgewählte Bild mit dem ImagePicker
    @IBAction func uploadPost(_ sender: Any) {
        if selectedCountry != "" && selectedCategory != "" {
            progressBarUpload.isHidden = false
            progressBarUpload.startAnimating()
            uploadButton.isEnabled = false
            let storage = Storage.storage()
            let storageReference = storage.reference()
       //  verwendet die Referenz der Bilder, die man in Firebase Storage hochgeladen hat. Man fügt es später der Datenbank hinzu
            let mediaFolder = storageReference.child("media").child(self.uid)
            if isImage {
                if let data = imageView.image?.jpegData(compressionQuality: 0.25){
                    let uuid = UUID().uuidString
                    let key = UUID().uuidString
                    let imageReference = mediaFolder.child("\(uuid).jpg")
                    imageReference.putData(data, metadata: nil) { storagemetadata, error in
                        // fehleranzeige wenn fehlgeschlagen ist
                        if error != nil {
                            Util().showAlert(title: "Error", message: error?.localizedDescription ?? "Uploading Error", self: self)
                            self.progressBarUpload.isHidden = true
                            self.progressBarUpload.stopAnimating()
                            self.uploadButton.isEnabled = true
                        } else{
                            imageReference.downloadURL { url, error in
                                // lädt zuerst das Bild in Firebase Storage hoch und nimmt dann die herunterladbare URL des hochgeladenen Bildes und fügt es der Firebase-Datenbank als Post-Modell hinzu
                                if error == nil {
                                    if let imageUrl = url?.absoluteString{
                                        let post = Post(userID: self.uid, downloadUrl: imageUrl, caption: self.captionTextView?.text ?? "", country: self.selectedCountry, category: self.selectedCategory, likeCount: 0, note: "", isImage: true, key: key, time: Date().millisecondsSince1970, thumbnail: "",senderName: self.senderName, senderProfilePic: self.senderProfilePic)
                                        let postDictionary = ["userID" : post.userID, "downloadUrl" : post.downloadUrl, "caption" : post.caption, "country": post.country, "category": post.category, "likeCount": post.likeCount, "note": post.note, "isImage": post.isImage, "key": post.key, "time": post.time, "thumbnail" : post.thumbnail, "senderName": post.senderName, "senderProfilePic": post.senderProfilePic] as [String : Any]
                                        
                                        let database = Database.database().reference(withPath: "Posts")
                                        
                                        database.child(self.uid).child(key).setValue(postDictionary) { error, reference in
                                            if error == nil {
                                                Database.database().reference().child("AllPosts").child(key).setValue(postDictionary)
                                                Database.database().reference().child("Countries").child(self.selectedCountry).setValue(self.selectedCountry)
                                                self.progressBarUpload.isHidden = true
                                                self.progressBarUpload.stopAnimating()
                                                self.clearUploadViewAfterUploaded()
                                                self.tabBarController?.selectedIndex = 1
                                            } else {
                                                Util().showAlert(title: "Error", message: error?.localizedDescription ?? "Uploading Error", self: self)
                                                self.progressBarUpload.isHidden = true
                                                self.progressBarUpload.stopAnimating()
                                                self.uploadButton.isEnabled = true
                                            }
                                        }
                                        
                                    }
                                    // error wenn fehlgeschlagen
                                } else {
                                    Util().showAlert(title: "Error", message: error?.localizedDescription ?? "Uploading Error", self: self)
                                    self.progressBarUpload.isHidden = true
                                    self.progressBarUpload.stopAnimating()
                                    self.uploadButton.isEnabled = true
                                }
                            }
                        }
                    }
                }
                // wenn video & thumbnail ausgwählt ist, wird es in Firebase-Speicher geladen
                // nimmt die herunterladbaren URLs der hochgeladenen Daten und lädt sie als Beitrag in die Firebase-Datenbank hoch
            } else {
                let uuid = UUID().uuidString
                let key = UUID().uuidString
                let thumbnailKey = UUID().uuidString
                let videoReference = mediaFolder.child("\(uuid).mov")
                let thumbnailReference = mediaFolder.child("\(thumbnailKey).jpg")
                videoReference.putFile(from: self.videoUrl as URL, metadata: nil) { metadata, error in
                    // fehler beim upload bei video
                    if error != nil {
                        Util().showAlert(title: "Error", message: error?.localizedDescription ?? "Uploading Error", self: self)
                        self.progressBarUpload.isHidden = true
                        self.progressBarUpload.stopAnimating()
                        self.uploadButton.isEnabled = true
                    } else {
                        if let data = self.thumbnail.jpegData(compressionQuality: 0.25){
                            thumbnailReference.putData(data, metadata: nil) { metadata, error in
                                if error != nil {
                                    Util().showAlert(title: "Error", message: "Uploading Error", self: self)
                                    self.progressBarUpload.isHidden = true
                                    self.progressBarUpload.stopAnimating()
                                    self.uploadButton.isEnabled = true
                                } else {
                                    thumbnailReference.downloadURL { url, error in
                                        if error != nil {
                                            Util().showAlert(title: "Error", message: "Uploading Error", self: self)
                                            self.progressBarUpload.isHidden = true
                                            self.progressBarUpload.stopAnimating()
                                            self.uploadButton.isEnabled = true
                                        } else {
                                            if let thumbnailUrl = url?.absoluteString {
                                                Database.database().reference().child("Posts").child(self.uid).child(key).child("thumbnail").setValue(thumbnailUrl) { error, reference in
                                                    if error == nil {
                                                        videoReference.downloadURL { url, error in
                                                            if error == nil {
                                                                if let uploadedVideoUrl = url?.absoluteString{
                                                                    let post = Post(userID: self.uid, downloadUrl: uploadedVideoUrl, caption: self.captionTextView?.text ?? "", country: self.selectedCountry, category: self.selectedCategory, likeCount: 0, note: "", isImage: false, key: key, time: Date().millisecondsSince1970, thumbnail: thumbnailUrl,senderName: self.senderName, senderProfilePic: self.senderProfilePic)
                                                                    let postDictionary = ["userID" : post.userID, "downloadUrl" : post.downloadUrl, "caption" : post.caption, "country": post.country, "category": post.category, "likeCount": post.likeCount, "note": post.note, "isImage": post.isImage, "key" : post.key, "time": post.time, "thumbnail" : post.thumbnail, "senderName": post.senderName, "senderProfilePic": post.senderProfilePic] as [String : Any]
                                                                    
                                                                    let database = Database.database().reference(withPath: "Posts")
                                                                    
                                                                    database.child(self.uid).child(key).setValue(postDictionary) { error, reference in
                                                                        if error == nil {
                                                                            Database.database().reference().child("AllPosts").child(key).setValue(postDictionary)
                                                                            Database.database().reference().child("Countries").child(self.selectedCountry).setValue(self.selectedCountry)
                                                                            self.progressBarUpload.isHidden = true
                                                                            self.progressBarUpload.stopAnimating()
                                                                            self.clearUploadViewAfterUploaded()
                                                                            self.tabBarController?.selectedIndex = 0
                                                                        } else {
                                                                            Util().showAlert(title: "Error", message: error?.localizedDescription ?? "Uploading Error", self: self)
                                                                            self.progressBarUpload.isHidden = true
                                                                            self.progressBarUpload.stopAnimating()
                                                                            self.uploadButton.isEnabled = true
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                            } else {
                                                                Util().showAlert(title: "Error", message: error?.localizedDescription ?? "Uploading Error", self: self)
                                                                self.progressBarUpload.isHidden = true
                                                                self.progressBarUpload.stopAnimating()
                                                                self.uploadButton.isEnabled = true
                                                            }
                                                        }
                                                    } else {
                                                        Util().showAlert(title: "Error", message: error?.localizedDescription ?? "Uploading Error", self: self)
                                                        self.progressBarUpload.isHidden = true
                                                        self.progressBarUpload.stopAnimating()
                                                        self.uploadButton.isEnabled = true
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
            
                /*
                 
                 */
                
            }
        } else {
            Util().showAlert(title: "Error", message: "Missing Info, please fill the all fields", self: self)
        }
            
    }
    // Nachdem der Benutzer den Beitrag hochgeladen hat, wird alles, was er ausgewählt hat, als Standard
    func clearUploadViewAfterUploaded(){
        selectedCountry = ""
        selectedCategory = ""
        captionTextView.text = "Add a caption..."
        captionTextView.textColor = UIColor.lightGray
        captionTextView.contentInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        imageView.isHidden = true
        locationLabel.text = "Add a location"
        locationLabel.textColor = UIColor.lightGray
        locationIcon.tintColor = UIColor.lightGray
    }
    
    // Sobald man eine location auswählt wird callback eingesetzt
    // ausgewählte location geht ins upload seite also es wird zurückgerufen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let locationVC = segue.destination as? LocationViewController {
            locationVC.callback = { country in
                    self.selectedCountry = country
                    self.locationLabel.text = self.selectedCountry
                    self.locationLabel.textColor = UIColor.systemBlue
                    self.locationIcon.tintColor = UIColor.systemBlue
                }
            }
    }
      
    // geht zu locationviewvcontroller
    @objc func selectLocation(){
        performSegue(withIdentifier: "toLocationVC", sender: nil)
    }
    
    // wählt foto aus der galerie
    @objc func selectImage(){
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController, animated: true) {
            self.isImage = true
        }
    }
    // wählt video aus der galerie
    @objc func selectVideo(){
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.movie"]
        present(imagePickerController, animated: true) {
            self.isImage = false
            
        }
    }
    
    // bringt Informationen, wenn der Benutzer ein Foto oder Video auswählt und zur Anwendung zurückkehrt
    // prüft, ob es sich bei dem ausgewählten um ein Video oder ein Foto handelt
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if imagePickerController.mediaTypes == ["public.image"]{
            imageView.isHidden = false
            uploadButton.isEnabled = true
            imageView.contentMode = .scaleAspectFill
            imageView.image = info[.originalImage] as? UIImage
           
        }else{
            imageView.isHidden = false
            uploadButton.isEnabled = true
            imageView.contentMode = .scaleAspectFit
            imageView.image = generateThumbnail(path: info[.mediaURL] as! URL)
            if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
                   // we selected a video
                videoUrl = videoURL
                do {
                                if #available(iOS 13, *) {
                                    //If on iOS13 slice the URL to get the name of the file
                                    let urlString = videoURL.relativeString

                                    let urlSlices = urlString.split(separator: ".")
                                    //Create a temp directory using the file name
                                    let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                                    videoUrl = tempDirectoryURL.appendingPathComponent(String(urlSlices[1])).appendingPathExtension(String(urlSlices[2])) as NSURL

                                    //Copy the video over
                                    try FileManager.default.copyItem(at: videoURL as URL, to: self.videoUrl! as URL)
                                }
                            }
                            catch let error {
                                print(error.localizedDescription)
                            }
            }
                      
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // wenn nutzer mit schreiben beginnt, ändert sich die textfarbe in schwarz
    func textViewDidBeginEditing(_ captionTextView: UITextView) {
        if captionTextView.textColor == UIColor.lightGray {
            captionTextView.text = nil
            captionTextView.textColor = UIColor.black
        }
    }
    // wenn der nutzer noch keinen eintrag gemacht hat, wird add a caption angezeigt
    func textViewDidEndEditing(_ captionTextView: UITextView) {
        if captionTextView.text.isEmpty || captionTextView.text == nil || captionTextView.text.count == 0{
            captionTextView.text = "Add a caption..."
            captionTextView.textColor = UIColor.lightGray
        }
    }
    // thumbnail wird erstellt
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            self.thumbnail = thumbnail
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
  
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        label.text = pickerData[row]
        label.sizeToFit()
        return label
    }
    
    // anzahl von "select category" komponenten
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
   // anzahl von Zeilen
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
        {
            pickerData.count
        }
    
    // Höhe von Kategorie auswahl von "select category", die graue Hülle
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
        {
            return 60
        }
    
   // öffnet eine Auswahl und zeigt die Kategorien an, die man bereits definiert hat
   // Es gibt die Kategoriedaten zurück
    @IBAction func addCategory(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height:screenHeight))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "Select a Category", message: "", preferredStyle: .actionSheet)
                
                alert.popoverPresentationController?.sourceView = categoryButton
                alert.popoverPresentationController?.sourceRect = categoryButton.bounds
                
                alert.setValue(vc, forKey: "contentViewController")
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { (UIAlertAction) in
                    self.selectedRow = pickerView.selectedRow(inComponent: 0)
                  
                    let selected = self.pickerData[self.selectedRow]
                    print(selected)
                    
                    self.categoryButton.titleLabel?.text = "  " + selected
                    self.selectedCategory = selected
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
    }
    
}

