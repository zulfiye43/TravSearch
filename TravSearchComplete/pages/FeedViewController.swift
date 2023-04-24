//
//  FeedViewController.swift
//  TravSearchComplete
//


import UIKit
import Firebase
import SDWebImage

// auf der Feedview sind alle Beiträge von verschiedenen Benutzer aus verschiedenen Ländern
// lediglich ohne 100 like funktion
// länder werden als button angezeigt, sobald man über das land im Bietrag als location angibt
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var labelText: String = ""
    var posts = [Post]()
    var likedPosts = [String]()
    var savedPosts = [String]()
    var countries = [String]()
    var arrIndex = [Int]()
    var isFirstElement = true
    var selectedIndex = 0
    
    var postLikeCount = [String:Int]()
    
    var selectedPost : Post?
    var userID = ""
    var username = ""
    var userPP = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.tableView.separatorColor = UIColor.clear
        
        getCountries()
        getLikedPost()
        getSavedPost()
        getUserInfo()
    }
    
    // alle likes werden abgerufen
    // verbindung zu firebase realtime database wird hergestellt
    // Dictionary-Daten werden in ein LikedPosts-Array konvertiert und gespeichert
    func getLikedPost(){
        Database.database().reference().child("LikedPosts").child(Auth.auth().currentUser!.uid).observe(.value) { snapshot in
            self.likedPosts.removeAll()
            for i in snapshot.children{
                if let childSnapshot = i as? DataSnapshot{
                    if let value = childSnapshot.value as? NSDictionary{
                        for j in value.allKeys{
                            if let keyData = j as? String {
                                self.likedPosts.append(keyData)
                            }
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    // informationen über den user aus realtime database
    func getUserInfo() {
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).observe(.value) { snapshot in
            if let value = snapshot.value as? NSDictionary {
                self.username = value["username"] as? String ?? ""
                self.userPP = value["profilePic"] as? String ?? ""
            }
        }
    }
    // alle gespeicherten Beiträge werden abgerufen
    // verbindung zu firebase realtime database wird hergestellt
    // Dictionary-Daten werden in ein savedPosts-Array konvertiert und gespeichert
    func getSavedPost(){
        Database.database().reference().child("SavedPosts").child(Auth.auth().currentUser!.uid).observe(.value) { snapshot in
            self.savedPosts.removeAll()
            for i in snapshot.children{
                if let childSnapshot = i as? DataSnapshot{
                    if let value = childSnapshot.value as? NSDictionary{
                        for j in value.allKeys{
                            if let keyData = j as? String {
                                self.savedPosts.append(keyData)
                            }
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
   
    // alle Beiträge werden aufgenommen
    // verbindung mit Firebase realtime database wird hergestellt
    // Dictionary-Daten werden in ein Posts-Array konvertiert und gespeichert
    func getPost(index: Int){
        var country = ""
        if countries.count > 0 {
            country = countries[index]
        }
        Database.database().reference().child("AllPosts").observe(.value) { snapshot in
            self.posts.removeAll()
            for i in snapshot.children {
                if let childSnapshot = i as? DataSnapshot {
                    if let value = childSnapshot.value as? NSDictionary{
                        if let countryData = value["country"] as? String{
                            if country == countryData{
                                let post = Post(userID: value["userID"] as? String ?? "", downloadUrl: value["downloadUrl"] as? String ?? "", caption: value["caption"] as? String ?? "", country: value["country"] as? String ?? "", category: value["category"] as? String ?? "", likeCount: value["likeCount"] as? Int ?? 0, note: value["note"] as? String ?? "", isImage: value["isImage"] as? Bool ?? true, key: value["key"] as? String ?? "", time: value["time"] as? Int64 ?? 1600000000, thumbnail: value["thumbnail"] as? String ?? "", senderName: value["senderName"] as? String ?? "",senderProfilePic: value["senderProfilePic"] as? String ?? "")
                                self.postLikeCount[post.key] = post.likeCount
                                self.posts.append(post)
                            }
                        }
                    }
                }
            }
           
            self.tableView.reloadData()
        }
    }
    
    // alle länder werden abgerufen
    // verbindung zu firebase realtime database wird hergestellt
    // Dictionary-Daten werden in ein countries-Array konvertiert und gespeichert
    func getCountries(){
        Database.database().reference().child("Countries").observe(.value) { snapshot in
            self.countries.removeAll()
            for i in snapshot.children {
                if let childSnapshot = i as? DataSnapshot {
                    if let value = childSnapshot.key as? String{
                        self.countries.append(value)
                    }
                }
            }
            self.getPost(index: 0)
            self.collectionView.reloadData()
        }
    }
    // wie viele Zellen in der tableview angezeigt werden
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    // was in der Zelle alles angezeigt werden soll auf der Feedview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        
        cell.postLikeCountLabel.text = "\(posts[indexPath.row].likeCount) like"
        
        // wenn der Beitrag geliket wird für likebutton
        let isLiked = self.likedPosts.contains(posts[indexPath.row].key)
        if isLiked {
            cell.postLikeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            cell.postLikeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        // Time Ago with extension of date
        let timeData = Int64(posts[indexPath.row].time)
        let date = Date(timeIntervalSince1970: Double(timeData) / 1000)
        cell.postTimeLabel.text = date.timeAgoDisplay()
        
        cell.likedButtonAction = { [unowned self] in
            
            // wenn user like zurückzieht
            // like wird aus database gelöscht
            if isLiked{
                cell.postLikeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                Database.database().reference().child("AllPosts").child(self.posts[indexPath.row].key).child("likeCount").setValue(self.postLikeCount[self.posts[indexPath.row].key]! - 1)
                Database.database().reference().child("Posts").child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).child("likeCount").setValue(self.postLikeCount[self.posts[indexPath.row].key]! - 1)
                Database.database().reference().child("LikedPosts").child(Auth.auth().currentUser!.uid).child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).removeValue()
                Database.database().reference().child("Notifications").child(posts[indexPath.row].userID).child(Auth.auth().currentUser!.uid).child(posts[indexPath.row].key).removeValue()
            } else {
                // wenn like behalten wird
                // like wird hinzugefügt in Database
                cell.postLikeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                let post = posts[indexPath.row]
                let postDictionary = ["userID" : post.userID, "downloadUrl" : post.downloadUrl, "caption" : post.caption, "country": post.country, "category": post.category, "likeCount": post.likeCount, "note": post.note, "isImage": post.isImage, "key": post.key, "time": post.time, "thumbnail" : post.thumbnail, "senderName": post.senderName, "senderProfilePic": post.senderProfilePic] as [String : Any]
                Database.database().reference().child("AllPosts").child(self.posts[indexPath.row].key).child("likeCount").setValue(self.postLikeCount[self.posts[indexPath.row].key]! + 1)
                Database.database().reference().child("Posts").child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).child("likeCount").setValue(self.postLikeCount[self.posts[indexPath.row].key]! + 1)
                
                // Benachrichtigunsmodel wird verwendet
                var notificationModel : LikedModel
                
                if posts[indexPath.row].isImage {
                    notificationModel = LikedModel(senderID: Auth.auth().currentUser!.uid, postKey: posts[indexPath.row].key, time: Date().millisecondsSince1970, receiverID: posts[indexPath.row].userID, senderPP: self.userPP, senderUsername: self.username, postURL: posts[indexPath.row].downloadUrl)
                } else {
                    notificationModel = LikedModel(senderID: Auth.auth().currentUser!.uid, postKey: posts[indexPath.row].key, time: Date().millisecondsSince1970, receiverID: posts[indexPath.row].userID, senderPP: self.userPP, senderUsername: self.username, postURL: posts[indexPath.row].thumbnail)
                }
                
                // verbindung mit realtime database, informationen werden eingetragen
                let notificationDictionary = ["senderID" : notificationModel.senderID, "postKey" : notificationModel.postKey, "time" : notificationModel.time, "receiverID" : notificationModel.receiverID, "senderPP" : notificationModel.senderPP, "senderUsername" : notificationModel.senderUsername, "postURL" : notificationModel.postURL] as [String : Any]
                
                Database.database().reference().child("LikedPosts").child(Auth.auth().currentUser!.uid).child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).setValue(postDictionary)
                Database.database().reference().child("Notifications").child(posts[indexPath.row].userID).child(Auth.auth().currentUser!.uid).child(posts[indexPath.row].key).setValue(notificationDictionary)
            }
        }
        
        // wenn ein Beitrag gespeichert wird für das gespeichert button
        let isSaved = self.savedPosts.contains(posts[indexPath.row].key)
        if isSaved {
            cell.postSaveButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        } else {
            cell.postSaveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
    
        cell.saveButtonAction = { [unowned self] in
            // wenn angeklickt, dann rausnehmen datei also entleeren und löscht aus database, wenn man gespiecherte Beitrag zurückzieht
            // ab else wird alles gespeichert da nutzer es nicht zurückgezogen hat
            if isSaved{
                cell.postSaveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
                Database.database().reference().child("SavedPosts").child(Auth.auth().currentUser!.uid).child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).removeValue()
            } else {
                let post = posts[indexPath.row]
                let postDictionary = ["userID" : post.userID, "downloadUrl" : post.downloadUrl, "caption" : post.caption, "country": post.country, "category": post.category, "likeCount": post.likeCount, "note": post.note, "isImage": post.isImage, "key": post.key, "time": post.time, "thumbnail" : post.thumbnail, "senderName": post.senderName, "senderProfilePic": post.senderProfilePic] as [String : Any]
                Database.database().reference().child("SavedPosts").child(Auth.auth().currentUser!.uid).child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).setValue(postDictionary)
                cell.postSaveButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            }
        }
        
        // damit man auf feedview auf profilbild eines users klickt, kann man auf die seite des users gelangen
        cell.userProfileImageAction = {
            self.userID = self.posts[indexPath.row].userID
            self.performSegue(withIdentifier: "goToUserProfileFromFeed", sender: nil)
        }
        
        // hier wird das geposte bearbeitet also die hülle/äußere, username usw angegeben
        cell.postUsernameLabel.text = posts[indexPath.row].senderName
        // falls es ein video ist dann kommt playbutton zum einsatz, dann sieht man playbutton auf dem screen damit kann der user das unterscheiden
        if posts[indexPath.row].isImage {
            cell.postPlayButton.isHidden = true
            cell.postImageView.sd_setImage(with: URL(string: posts[indexPath.row].downloadUrl), completed: nil)
        } else {
            cell.postPlayButton.isHidden = false
            cell.postImageView.sd_setImage(with: URL(string: posts[indexPath.row].thumbnail), completed: nil)
        }
        
        cell.postProfileImageView.sd_setImage(with: URL(string: posts[indexPath.row].senderProfilePic), completed: nil)
        
        return cell
    }
    
    // wenn der nutzer mehr wissen möchte über den post, klickt an und es werden detailierte informationen angezeigt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPost = posts[indexPath.row]
        performSegue(withIdentifier: "toDetailFromFeed", sender: nil)
    }
    
//  bevor es zum segue kommt muss alles vorbereitet werden und damit läuft erst prepare dann segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDetailFromFeed"){
            
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.post = selectedPost
        } else if segue.identifier == "goToUserProfileFromFeed" {
            let destinationVC = segue.destination as! UserProfileViewController
            destinationVC.userID = self.userID
        }
    }
        // zeigt an, wie viele Abschnitte sich in der Sammlungsansicht befinden
        // zeilenanzahl für country liste/ansicht
    func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 1
    }
    // zeigt, wie viele Elemente in den Abschnitten in der collectionView angezeigt werden, hier: länder
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count
    }
    
    
    // zelle für die länder anisicht
    // wird mit Collectioncell verbunden
    // ändern text des labels
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        cell.countryLabel.text = countries[indexPath.row]
        cell.countryLabel.layer.cornerRadius = 20
        cell.countryLabel.textColor = UIColor.systemGreen
        
        if indexPath.row != 0 {
            isFirstElement = false
        }
        // hier wird das button für country grün gemacht, wenn man ohne zu klicken auf die feedvieew seite gelangt
        if arrIndex.contains(indexPath.item) || isFirstElement{
            cell.countryLabel.backgroundColor = UIColor.systemGreen
            cell.countryLabel.textColor = UIColor.white
            cell.countryLabel.clipsToBounds = true
        } else {
            isFirstElement = false
            cell.countryLabel.backgroundColor = UIColor(red: 183/255, green: 213/255, blue: 172/255, alpha: 0.5)
            cell.countryLabel.textColor = UIColor.systemGreen
            cell.countryLabel.clipsToBounds = true
        }
        
        return cell
    }
    // layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: countries[indexPath.item].size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)]).width + 25, height: 30)
    }
    // ausgewählte land wird in die liste hinzugefügt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isFirstElement = false
        if !arrIndex.contains(indexPath.item) {
            arrIndex.removeAll()
            arrIndex.append(indexPath.item)
            getPost(index: indexPath.row)
            collectionView.reloadData()
        }
 
    }
    // wenn es  nicht ausgewählt wurde, keine aktion
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if arrIndex.contains(indexPath.item) {
            arrIndex = arrIndex.filter { $0 != indexPath.item }
            collectionView.reloadData()
        }
    }
}


