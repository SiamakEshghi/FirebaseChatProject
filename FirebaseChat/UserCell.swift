//
//  UserCell.swift
//  FirebaseChat
//
//  Created by Siamak Eshghi on 2017-06-26.
//  Copyright © 2017 Joopooli. All rights reserved.
//

import UIKit


class UserCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
   
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
   
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
