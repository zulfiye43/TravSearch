//
//  UserProfileTableCell.swift
//  TravSearchComplete
//


import UIKit

// alle Eigenschaften was man für die zelle für Userprofile braucht
class UserProfileTableCell: UITableViewCell {

    
    var likedButtonAction : (() -> ())?
    var saveButtonAction : (() -> ())?
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var userPPImageView: CircleAvatar!
    
    @IBOutlet weak var playButton: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var savedButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
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
        
        self.likeButton.addTarget(self, action: #selector(likedButtonAction(_:)), for: .touchUpInside)
        self.savedButton.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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

