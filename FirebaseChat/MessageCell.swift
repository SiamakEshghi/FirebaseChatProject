//
//  MessageCell.swift
//  FirebaseChat
//
//  Created by Asal Rostami on 2017-07-09.
//  Copyright © 2017 Joopooli. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var messageImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var message: Message?{
        didSet{
            
            
            if let id = message?.chatPartnerId(){
                let ref = Database.database().reference().child("Users").child(id)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String:AnyObject]
                    {
                        self.nameLabel.text = dictionary["name"] as? String
                        self.messageImage?.kf.setImage(with: URL(string: dictionary["ProfileImageUrl"] as! String)!)
                    }
                })
            }
            
            self.descriptionLabel.text = message?.text
            self.timeLabel.text = message?.timestamp
        }
    }
    
    override func awakeFromNib() {
        
        
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

