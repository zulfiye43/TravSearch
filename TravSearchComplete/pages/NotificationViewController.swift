//
//  NotificationViewController.swift
//  TravSearchComplete
//


import UIKit
import Firebase
import SDWebImage

// benachrichtigungsseite, wo der nutzeer benachrichtig wird wenn ein beitrag geliket wird
class NotificationViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
     
    var notificationsList = [LikedModel]()
    var selectedPost : Post?
    var userID = ""
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        getLikedPost()
    }
    
    // alle likes werden abgerufen
    // verbindung zu firebase realtime database wird hergestellt
    // Dictionary-Daten werden in ein notificationsList-Array konvertiert und gespeichert
    func getLikedPost(){
        Database.database().reference().child("Notifications").child(Auth.auth().currentUser!.uid).queryOrdered(byChild: "time").observe(.value) { snapshot in
            self.notificationsList.removeAll()
            for i in snapshot.children {
                if let childSnapshot = i as? DataSnapshot {
                    for j in childSnapshot.children {
                        
                        if let child = j as? DataSnapshot {
                            if let value = child.value as? NSDictionary{
                                let notification = LikedModel(senderID: value["senderID"] as? String ?? "", postKey: value["postKey"] as? String ?? "", time: value["time"] as? Int64 ?? 1600000000, receiverID: value["receiverID"] as? String ?? "", senderPP: value["senderPP"] as? String ?? "", senderUsername: value["senderUsername"] as? String ?? "", postURL: value["postURL"] as? String ?? "")
                                if notification.receiverID != notification.senderID{
                                    self.notificationsList.append(notification)
                                }
                            }
                            
                            
                        }
                    }
                }
            }
            self.notificationsList.reverse()
            self.tableView.reloadData()
        }
    }
    // wie viele Zellen in der tableview angezeigt werden, hier: notificationsList
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationsList.count
    }
    // was in der Zelle alles angezeigt werden soll auf der NotificationView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        
        cell.notificationUsernameLabel.text = "\(notificationsList[indexPath.row].senderUsername) liked your post"
        cell.notificationPPImageView.sd_setImage(with: URL(string: notificationsList[indexPath.row].senderPP), completed: nil)
        cell.notificationPostImageView.sd_setImage(with: URL(string: notificationsList[indexPath.row].postURL), completed: nil)
        // Time Ago with extension of date
        let date = Date(timeIntervalSince1970: Double(notificationsList[indexPath.row].time / 1000))
        cell.notificationTimeLabel.text = date.timeAgoDisplay()
        
        // notification wird in database hinzugefügt
        cell.imageViewAction = {
            let key = self.notificationsList[indexPath.row].postKey
            
            Database.database().reference().child("AllPosts").child(key).observeSingleEvent(of: .value) { snapshot in
                if let value = snapshot.value as? NSDictionary{
                    print(value)
                    
                    let post = Post(userID: value["userID"] as? String ?? "", downloadUrl: value["downloadUrl"] as? String ?? "", caption: value["caption"] as? String ?? "", country: value["country"] as? String ?? "", category: value["category"] as? String ?? "", likeCount: value["likeCount"] as? Int ?? 0, note: value["note"] as? String ?? "", isImage: value["isImage"] as? Bool ?? true, key: value["key"] as? String ?? "", time: value["time"] as? Int64 ?? 1600000000, thumbnail: value["thumbnail"] as? String ?? "", senderName: value["senderName"] as? String ?? "",senderProfilePic: value["senderProfilePic"] as? String ?? "")
                    self.selectedPost = post
                    self.goToDetail(post: self.selectedPost)
                }
            }
        }

        // wenn man auf profilbild klickt bei notifications, kommt profil seite des users
        cell.ppImageViewAction = {
            self.userID = self.notificationsList[indexPath.row].senderID
            self.goToUserPRofile(id: self.userID)
        }
        return cell
    }
    
    // zu userprofile gehen
    func goToUserPRofile(id: String){
        if id != "" {
            performSegue(withIdentifier: "goToUserProfileFromNot", sender: nil)
        }
    }
    // zu detail gehen
    func goToDetail(post: Post?){
        if selectedPost != nil {
            performSegue(withIdentifier: "goToDetailFromNotifications", sender: nil)
        }
    }
    
    
    //  bevor es zum segue kommt muss alles vorbereitet werden und damit läuft erst prepare dann segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToDetailFromNotifications"){
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.post = selectedPost
        } else if segue.identifier == "goToUserProfileFromNot" {
            let destinationVC = segue.destination as! UserProfileViewController
            destinationVC.userID = userID
        }
    }
}

