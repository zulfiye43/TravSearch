//
//  ProfileCollectionCell.swift
//  TravSearchComplete
//


import UIKit

// alle Eigenschaften was man für die zelle eines profiles braucht
class ProfileCollectionCell: UICollectionViewCell {
    
    var deleteButtonAction : (() -> ())?
    var saveButtonAction : (() -> ())?
    @objc var savedProfileImageAction : (() -> ())?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var likedView: UIView!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var postCountryLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel! //Post Category Label
    @IBOutlet weak var postLikeCount: UILabel!
    @IBOutlet weak var savedProfileImageView: CircleAvatar!
    @IBOutlet weak var savedUsernameLabel: UILabel!
    @IBOutlet weak var savedTimeLabel: UILabel!
    @IBOutlet weak var savedButton: UIButton!
    @IBOutlet weak var playButton: UIImageView!
    
    // Eigenschaften der Komponenten in der Zelle wird festgelegt
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 40.0
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        cardView.layer.cornerRadius = 40.0
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray5.cgColor
        
        savedProfileImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(saveProfileImageAction))
        savedProfileImageView.addGestureRecognizer(gestureRecognizer)
        
        self.deleteButton.addTarget(self, action: #selector(deleteButtonAction(_:)), for: .touchUpInside)
        
        self.savedButton.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
    }
    
    @objc func saveProfileImageAction(){
        savedProfileImageAction?()
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton){
      // if the closure is defined (not nil)
      // then execute the code inside the subscribeButtonAction closure
        deleteButtonAction?()
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton){
      // if the closure is defined (not nil)
      // then execute the code inside the subscribeButtonAction closure
        saveButtonAction?()
    }
    
    
    
}

