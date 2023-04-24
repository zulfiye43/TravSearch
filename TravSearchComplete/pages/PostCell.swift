//
//  PostCell.swift
//  TravSearchComplete
//


import UIKit

// alle Eigenschaften was man für die zelle eines beitrags braucht
class PostCell: UITableViewCell {

    
    var likedButtonAction : (() -> ())?
    var saveButtonAction : (() -> ())?
    @objc var userProfileImageAction : (() -> ())?
    
    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var postUsernameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var postSaveButton: UIButton!
    @IBOutlet weak var postLikeButton: UIButton!
    @IBOutlet weak var postProfileImageView: CircleAvatar!
    @IBOutlet weak var postLikeCountLabel: UILabel!
    @IBOutlet weak var postPlayButton: UIImageView!
    
// Eigenschaften der Komponenten in der Zelle wird festgelegt
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.backgroundColor = UIColor.white
       
        cardView.layer.cornerRadius = 10.0

        cardView.layer.shadowColor = UIColor.gray.cgColor

        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)

        cardView.layer.shadowRadius = 6.0

        cardView.layer.shadowOpacity = 0.7
        
        postImageView.layer.cornerRadius = 10.0
        postImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        postProfileImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userProfileImageActionSelector))
        postProfileImageView.addGestureRecognizer(gestureRecognizer)
        
        self.postLikeButton.addTarget(self, action: #selector(likedButtonAction(_:)), for: .touchUpInside)
        self.postSaveButton.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
    }
    
    
    @objc func userProfileImageActionSelector(){
        userProfileImageAction?()
    }
    
    @IBAction func likedButtonAction(_ sender: UIButton){
      // if the closure is defined (not nil)
      // then execute the code inside the subscribeButtonAction closure
        likedButtonAction?()
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton){
      // if the closure is defined (not nil)
      // then execute the code inside the subscribeButtonAction closure
        saveButtonAction?()
    }
}

