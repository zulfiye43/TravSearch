//
//  UserProfileViewController.swift
//  TravSearchComplete
//

import UIKit
import Firebase
import SDWebImage

// auf das Profil des Users gehen
class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userPPImageView: CircleAvatar!
    @IBOutlet weak var cardView: UIView!
    
    var userID = ""
    var posts = [Post]()
    var likedPosts = [String]()
    var savedPosts = [String]()
    var postLikeCount = [String : Int]()
    
    var userPP = ""
    var username = ""
    
    var selectedPost : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        setView()
        getUser()
        getPosts()
        getLikedPost()
        getSavedPost()
        print(userID)
    }
    
    // Eigenschaften der Komponenten in der Zelle wird festgelegt
    func setView(){
        cardView.backgroundColor = UIColor.white
       
        cardView.layer.cornerRadius = 10.0

        cardView.layer.shadowColor = UIColor.systemGreen.cgColor

        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)

        cardView.layer.shadowRadius = 6.0

        cardView.layer.shadowOpacity = 0.7
        
        cardView.layer.cornerRadius = 10.0
        
        userPPImageView.layer.shadowColor = UIColor.gray.cgColor

        userPPImageView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)

        userPPImageView.layer.shadowRadius = 6.0

        userPPImageView.layer.shadowOpacity = 1
    }
    
    // informationen über den user aus realtime database
    func getUserInfo(){
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? NSDictionary {
                self.userPP = value["profilePic"] as? String ?? ""
                self.username = value["username"] as? String ?? "Not Found"
            }
        }
    }
    
    // Ein Klick auf das Profilfoto des Benutzers führt zu seiner Profilseite. Hier werden die Informationen dieses Benutzers abgerufen
    func getUser(){
        Database.database().reference().child("Users").child(userID).observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? NSDictionary {
                let name = value["name"] as? String ?? "Not Found"
                let username = value["username"] as? String ?? "Not Found"
                let profilePic = value["profilePic"] as? String ?? ""
                
                self.userPPImageView.sd_setImage(with: URL(string: profilePic), completed: nil)
                self.imageView.sd_setImage(with: URL(string: profilePic), completed: nil)
                self.usernameLabel.text = "@\(username)"
                self.nameLabel.text = name
            }
        }
    }
    
    // alle Beiträge werden aufgenommen
    // verbindung mit Firebase realtime database wird hergestellt
    // Dictionary-Daten werden in ein Posts-Array konvertiert und gespeichert
    func getPosts(){
        Database.database().reference().child("Posts").child(userID).queryOrdered(byChild: "time").observe(.value) { snapshot in
            self.posts.removeAll()
            var likeCount = 0
            for i in snapshot.children {
                if let childrenSnap = i as? DataSnapshot {
                    if let value = childrenSnap.value as? NSDictionary{
                        let post = Post(userID: value["userID"] as? String ?? "", downloadUrl: value["downloadUrl"] as? String ?? "", caption: value["caption"] as? String ?? "", country: value["country"] as? String ?? "", category: value["category"] as? String ?? "", likeCount: value["likeCount"] as? Int ?? 0, note: value["note"] as? String ?? "", isImage: value["isImage"] as? Bool ?? true, key: value["key"] as? String ?? "", time: value["time"] as? Int64 ?? 1400000000, thumbnail: value["thumbnail"] as? String ?? "", senderName: value["senderName"] as? String ?? "",senderProfilePic: value["senderProfilePic"] as? String ?? "")
                        likeCount += post.likeCount
                        self.postLikeCount[post.key] = post.likeCount
                        self.posts.append(post)
                    }
                }
            }
            self.likeCountLabel.text = "\(likeCount)"
            self.posts.reverse()
            self.postCountLabel.text = String(self.posts.count)
            self.tableView.reloadData()
        }
    }
    
    // alle likes werden abgerufen
    // verbindung zu firebase realtime database wird hergestellt
    // Dictionary-Daten werden in ein LikedPosts-Array konvertiert und gespeichert
    func getLikedPost(){
        Database.database().reference().child("LikedPosts").child(Auth.auth().currentUser!.uid).child(userID).observe(.value) { snapshot in
            self.likedPosts.removeAll()
            for i in snapshot.children {
                if let childrenSnap = i as? DataSnapshot {
                    self.likedPosts.append(childrenSnap.key)
                }
            }
            self.tableView.reloadData()
        }
    }
    // alle gespeicherten Beiträge werden abgerufen
    // verbindung zu firebase realtime database wird hergestellt
    // Dictionary-Daten werden in ein savedPosts-Array konvertiert und gespeichert
    func getSavedPost(){
        Database.database().reference().child("SavedPosts").child(Auth.auth().currentUser!.uid).child(userID).observe(.value) { snapshot in
            self.savedPosts.removeAll()
            for i in snapshot.children {
                if let childrenSnap = i as? DataSnapshot {
                    self.savedPosts.append(childrenSnap.key)
                }
            }
            self.tableView.reloadData()
        }
    }
    // wie viele Zellen in der tableview angezeigt werden
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    // was in der Zelle alles angezeigt werden soll auf der Userprofileview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileTableCell", for: indexPath) as! UserProfileTableCell
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        
        cell.usernameLabel.text = posts[indexPath.row].senderName
        cell.userPPImageView.sd_setImage(with: URL(string: posts[indexPath.row].senderProfilePic), completed: nil)
        // Time Ago with extension of date
        let date = Date(timeIntervalSince1970: Double(posts[indexPath.row].time / 1000))
        cell.timeLabel.text = date.timeAgoDisplay()
        cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount) like"
        
        if posts[indexPath.row].isImage {
            cell.postImageView.sd_setImage(with: URL(string: posts[indexPath.row].downloadUrl), completed: nil)
            cell.playButton.isHidden = true
        }else {
            cell.postImageView.sd_setImage(with: URL(string: posts[indexPath.row].thumbnail), completed: nil)
            cell.playButton.isHidden = false
        }
        // wenn der Beitrag geliket wird für likebutton
        let isLiked = self.likedPosts.contains(posts[indexPath.row].key)
        if isLiked {
            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        cell.likedButtonAction = { [unowned self] in
            // wenn user like zurückzieht
            // like wird aus database gelöscht
            if isLiked{
                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                Database.database().reference().child("AllPosts").child(self.posts[indexPath.row].key).child("likeCount").setValue(self.postLikeCount[self.posts[indexPath.row].key]! - 1)
                Database.database().reference().child("Posts").child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).child("likeCount").setValue(self.postLikeCount[self.posts[indexPath.row].key]! - 1)
                Database.database().reference().child("LikedPosts").child(Auth.auth().currentUser!.uid).child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).removeValue()
                Database.database().reference().child("Notifications").child(posts[indexPath.row].userID).child(Auth.auth().currentUser!.uid).child(posts[indexPath.row].key).removeValue()
            } else {
                // wenn like behalten wird
                // like wird hinzugefügt in Database
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
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
                Database.database().reference().child("Notifications").child(self.userID).child(Auth.auth().currentUser!.uid).child(posts[indexPath.row].key).setValue(notificationDictionary)
            }
        }
        
        // wenn ein Beitrag gespeichert wird für das gespeichert button
        let isSaved = self.savedPosts.contains(posts[indexPath.row].key)
        if isSaved {
            cell.savedButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        } else {
            cell.savedButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
    
        cell.saveButtonAction = { [unowned self] in
            // wenn angeklickt, dann rausnehmen datei also entleeren und löscht aus database, wenn man gespiecherte Beitrag zurückzieht
            // ab else wird alles gespeichert da nutzer es nicht zurückgezogen hat
            if isSaved{
                cell.savedButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
                Database.database().reference().child("SavedPosts").child(Auth.auth().currentUser!.uid).child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).removeValue()
            } else {
                let post = posts[indexPath.row]
                let postDictionary = ["userID" : post.userID, "downloadUrl" : post.downloadUrl, "caption" : post.caption, "country": post.country, "category": post.category, "likeCount": post.likeCount, "note": post.note, "isImage": post.isImage, "key": post.key, "time": post.time, "thumbnail" : post.thumbnail, "senderName": post.senderName, "senderProfilePic": post.senderProfilePic] as [String : Any]
                Database.database().reference().child("SavedPosts").child(Auth.auth().currentUser!.uid).child(self.posts[indexPath.row].userID).child(self.posts[indexPath.row].key).setValue(postDictionary)
                cell.savedButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            }
        }
        return cell
    }
    // wenn der nutzer mehr wissen möchte über den post, klickt an und es werden detailiertte informationen angezeigt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPost = posts[indexPath.row]
        performSegue(withIdentifier: "toDetailFromUserProfile", sender: nil)
    }
    //  bevor es zum segue kommt muss alles vorbereitet werden und damit läuft erst prepare dann segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailFromUserProfile" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.post = selectedPost
        }
    }
    
}

