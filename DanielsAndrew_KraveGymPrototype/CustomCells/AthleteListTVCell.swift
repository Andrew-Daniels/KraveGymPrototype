//
//  AthleteListTVCell.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 5/26/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

class AthleteListTVCell: UITableViewCell {

    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func profilePicture(user: User) {
        profileImageView.image = user.image
        initialsLabel.isHidden = user.isInitialsHidden()
        initialsLabel.text = user.initials
        firstNameLabel.text = user.firstName
        lastNameLabel.text = user.lastName
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.borderColor = user.borderColor
        profileImageView.layer.borderWidth = user.borderWidth
        profileImageView.layer.masksToBounds = true
    }

}
