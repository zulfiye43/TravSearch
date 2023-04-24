//
//  HomeViewController.swift
//  TravSearchComplete
//

import UIKit
import Firebase
import SDWebImage

// die Home Ansicht, wo man die hochgeladenen Beiträge sehen kann
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
     
    // für die Beiträge
    var posts = [Post]()
    var likedPosts = [String]()
    var savedPosts = [String]()
    
    var postLikeCount = [String:Int]()
    
    var username = ""
    var userPP = ""
    
    var selectedUser = ""
    var key : String?
    var selectedPost : Post?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        getPosts()
        getLikedPosts()
        getSavedPost()
        getUserInfo()
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
    
    // alle Beiträge werden aufgenommen
    // verbindung mit Firebase realtime database wird hergestellt
    // Dictionary-Daten werden in ein Post-Array konvertiert und gespeichert
    // Beiträge mit oder über 100 Likes erscheinen auf der Hauptseite
    func getPosts(){
        Database.database().reference().child("AllPosts").observe(.value) { snapshot in
            self.posts.removeAll()
            for i in snapshot.children {
                if let childSnapshot = i as? DataSnapshot {
                    if let value = childSnapshot.value as? NSDictionary{
                        if let likeCount = value["likeCount"] as? Int{
                            if likeCount >= 100{
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
    
    // alle likes werden abgerufen
    // verbindung zu firebase realtime database wird hergestellt
    // Dictionary-Daten werden in ein LikedPosts-Array konvertiert und gespeichert
    func getLikedPosts(){
        Database.database().reference().child("LikedPosts").child(Auth.auth().currentUser!.uid).observe(.value) { snapshot in
            self.likedPosts.removeAll()
            for i in snapshot.children{
                if let childSnapshot = i as? DataSnapshot{
                    if let value = childSnapshot.value as? NSDictionary{
                        for j in value.allKeys {
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
    
    // wie viele Zellen in der tableview angezeigt werden
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    // was in der Zelle alles angezeigt werden soll auf der Homeview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        
        // was ist der Zelle angezeigt wird: like count, profilbild und username
        cell.homeLikeCountLabel.text = "\(posts[indexPath.row].likeCount) Like"
        cell.homePPImageView.sd_setImage(with: URL(string: posts[indexPath.row].senderProfilePic), completed: nil)
        cell.homeUsernameLabel.text = posts[indexPath.row].senderName
        
        // Time Ago with extension of date
        let timeData = Int64(posts[indexPath.row].time)
        let date = Date(timeIntervalSince1970: Double(timeData) / 1000)
        cell.homeTimeLabel.text =  date.timeAgoDisplay()
        
        // wenn der Beitrag geliket wird für likebutton
        let isLiked = self.likedPosts.contains(posts[indexPath.row].key)
        if isLiked {
            cell.homeLikeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            cell.homeLikeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        // wenn der Beitrag ein Foto ist, dann wird playbutton versteckt, weil es nur für videos gedacht ist
        if posts[indexPath.row].isImage {
            cell.homePlayButton.isHidden = true
            cell.homePostImageView.sd_setImage(with: URL(string: posts[indexPath.row].downloadUrl), completed: nil)
        } else {
            cell.homePostImageView.sd_setImage(with: URL(string: posts[indexPath.row].thumbnail), completed: nil)
            cell.homePlayButton.isHidden = false
        }
        
       
        
        
        cell.likedButtonAction = { [unowned self] in
            
            if isLiked{
                
                // wenn user like zurückzieht
                // like wird aus database gelöscht
                cell.homeLikeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                Database.database().reference().child("AllPosts").child(self.posts[indexPath.row].key).child("likeCount").setValue(self.postLikeCount[self.posts[indexPath.row].key]! - 1)
                Database.database().reference().child("Posts").child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).child("likeCount").setValue(self.postLikeCount[self.posts[indexPath.row].key]! - 1)
                Database.database().reference().child("LikedPosts").child(Auth.auth().currentUser!.uid).child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).removeValue()
                Database.database().reference().child("Notifications").child(posts[indexPath.row].userID).child(Auth.auth().currentUser!.uid).child(posts[indexPath.row].key).removeValue()
            } else {
                // wenn like behalten wird
                // like wird hinzugefügt in Database
                key = UUID().uuidString
                cell.homeLikeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
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
            cell.homeSavedButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        } else {
            cell.homeSavedButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
    
        // wenn user gespeicherte beitrag zurückzieht
        // der gespeicherte beitrag wird aus database gelöscht
        cell.savedButtonAction = { [unowned self] in
            if isSaved{
                cell.homeSavedButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
                Database.database().reference().child("SavedPosts").child(Auth.auth().currentUser!.uid).child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).removeValue()
            } else {
                // wenn gespeicherter Beitrag behalten wird
                // gespeicherter Beitrag wird hinzugefügt in Database
                let post = posts[indexPath.row]
                let postDictionary = ["userID" : post.userID, "downloadUrl" : post.downloadUrl, "caption" : post.caption, "country": post.country, "category": post.category, "likeCount": post.likeCount, "note": post.note, "isImage": post.isImage, "key": post.key, "time": post.time, "thumbnail" : post.thumbnail, "senderName": post.senderName, "senderProfilePic": post.senderProfilePic] as [String : Any]
                Database.database().reference().child("SavedPosts").child(Auth.auth().currentUser!.uid).child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).setValue(postDictionary)
                cell.homeSavedButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            }
        }
        // damit man auf Homeview auf profilbild eines users klickt, kann man auf die seite des users gelangen
        cell.userProfileImageAction = { [unowned self] in
            self.selectedUser = posts[indexPath.row].userID
            self.performSegue(withIdentifier: "goToUserProfileFromHome", sender: nil)
        }
        
        return cell
    }
    // wenn der nutzer mehr wissen möchte über den post, klickt an und es werden detailiertte informationen angezeigt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPost = posts[indexPath.row]
        performSegue(withIdentifier: "toDetailFromHome", sender: nil)
    }
    // bevor es zum segue kommt muss alles vorbereitet werden und damit läuft erst prepare dann segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDetailFromHome"){
            
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.post = selectedPost
        } else if segue.identifier == "goToUserProfileFromHome"{
            let destinationVC = segue.destination as! UserProfileViewController
            destinationVC.userID = selectedUser
        }
    }
    
    
}

