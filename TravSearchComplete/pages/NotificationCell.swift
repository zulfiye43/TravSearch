//
//  NotificationCell.swift
//  TravSearchComplete
//


import UIKit

// alle Eigenschaften was man für die zelle für Notification braucht
class NotificationCell: UITableViewCell {

    @objc var imageViewAction : (() -> ())?
    @objc var ppImageViewAction : (() -> ())?
    @IBOutlet weak var notificationPPImageView: CircleAvatar!
    @IBOutlet weak var notificationUsernameLabel: UILabel!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var notificationPostImageView: UIImageView!
    
    // Eigenschaften der Komponenten in der Zelle wird festgelegt
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        notificationPostImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToPost))
        notificationPostImageView.addGestureRecognizer(gestureRecognizer)
        
        notificationPPImageView.isUserInteractionEnabled = true
        let gestureRecognizerPP = UITapGestureRecognizer(target: self, action: #selector(goToUserProfile))
        notificationPPImageView.addGestureRecognizer(gestureRecognizerPP)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func goToPost(){
        imageViewAction?()
    }
    
    @objc func goToUserProfile(){
        ppImageViewAction?()
    }

}

