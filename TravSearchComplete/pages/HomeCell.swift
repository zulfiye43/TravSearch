//
//  HomeCell.swift
//  TravSearchComplete
//


import UIKit

// alle Eigenschaften was man für die zelle von Home braucht
class HomeCell: UITableViewCell {
    
    var likedButtonAction : (() -> ())?
    var savedButtonAction : (() -> ())?
    @objc var userProfileImageAction : (() -> ())?

    @IBOutlet weak var homeCardView: UIView!
    @IBOutlet weak var homeUsernameLabel: UILabel!
    @IBOutlet weak var homeSavedButton: UIButton!
    @IBOutlet weak var homePostImageView: UIImageView!
    @IBOutlet weak var homeLikeButton: UIButton!
    @IBOutlet weak var homeLikeCountLabel: UILabel!
    @IBOutlet weak var homePPImageView: CircleAvatar!
    @IBOutlet weak var homeTimeLabel: UILabel!
    @IBOutlet weak var homePlayButton: UIImageView!
    
    // Eigenschaften der Komponenten in der Zelle wird festgelegt
    override func awakeFromNib() {
        super.awakeFromNib()
 
        
        homeCardView.backgroundColor = UIColor.white
       
        homeCardView.layer.cornerRadius = 10.0

        homeCardView.layer.shadowColor = UIColor.gray.cgColor

        homeCardView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)

        homeCardView.layer.shadowRadius = 6.0

        homeCardView.layer.shadowOpacity = 0.7
        
        homePostImageView.layer.cornerRadius = 10.0
        homePostImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        homePPImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userProfileImageActionSelector))
        homePPImageView.addGestureRecognizer(gestureRecognizer)
        
        self.homeLikeButton.addTarget(self, action: #selector(likedButtonAction(_:)), for: .touchUpInside)
        self.homeSavedButton.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
    }
    
    
    
    @IBAction func likedButtonAction(_ sender: UIButton){
      // if the closure is defined (not nil)
      // then execute the code inside the subscribeButtonAction closure
        likedButtonAction?()
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton){
      // if the closure is defined (not nil)
      // then execute the code inside the subscribeButtonAction closure
        savedButtonAction?()
    }
    
    @objc func userProfileImageActionSelector(){
        userProfileImageAction?()
    }
    
    

    

}

