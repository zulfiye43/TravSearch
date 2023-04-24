//
//  DetailViewController.swift
//  TravSearchComplete
//


import UIKit
import Firebase
import AVKit
import AVFoundation

// alle Details der Beiträge werden angezeigt
// Dies ist die Detailseite
class DetailViewController: UIViewController, AVPlayerViewControllerDelegate {
 
    // für das video um es abspielen zu lassen standard bei ios
    var playerController = AVPlayerViewController()
    
    var post : Post?
    @IBOutlet weak var detailImageView: UIImageView!
   
    @IBOutlet weak var detailPPImageView: CircleAvatar!
    @IBOutlet weak var detailLikeLabel: UIButton!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var detailUsernameLabel: UILabel!
    @IBOutlet weak var detailCountryLabel: UILabel!
    @IBOutlet weak var detailCategoryLabel: UILabel!
    @IBOutlet weak var detailPlayButton: UIImageView!
    @IBOutlet weak var detailCaptionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailPlayButton.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playButton))
        detailPlayButton.addGestureRecognizer(gestureRecognizer)
        
        setView()
        getUsername()
    }
    
    // um video abzuspielen
    func playVideo(){
        guard let url = URL(string: post?.downloadUrl ?? "") else {return}
        let player = AVPlayer(url: url)
        playerController = AVPlayerViewController()
        playerController.player = player
        playerController.allowsPictureInPicturePlayback = true
        playerController.delegate = self
        playerController.player?.play()
        
        self.present(playerController, animated: true,completion: nil)
    }
    // video abspielen
    @objc func playButton(){
        playVideo()
    }
    // wenn bild dann playbutton verbergen
    func setView(){
        if post?.isImage ?? false {
            detailImageView.sd_setImage(with: URL(string: post!.downloadUrl), completed: nil)
            detailPlayButton.isHidden = true
        } else {
            detailImageView.sd_setImage(with: URL(string: post!.thumbnail), completed: nil)
            detailPlayButton.isHidden = false
        }
        
        detailPPImageView.sd_setImage(with: URL(string: post!.senderProfilePic), completed: nil)
        detailLikeLabel.setTitle(String("  \(post!.likeCount)"), for: .normal)
        detailNameLabel.text = post!.senderName
 
        detailCountryLabel.text = post!.country
        detailCategoryLabel.text = post!.category
        detailCaptionLabel.text = post!.caption
        
    }
    // username wird abgerufen
    func getUsername() {
        Database.database().reference().child("Users").child(post!.userID).child("username").observeSingleEvent(of: .value) { snapshot in
            print(self.post!.userID)
            if let username = snapshot.value as? String{
                print("username")
                self.detailUsernameLabel.text = "@\(username)"
            }
        }
    }
    

}

