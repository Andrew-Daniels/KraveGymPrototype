//
//  AthleteListCVCell.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/12/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

class AthleteListCVCell: UICollectionViewCell {
    
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    func profilePicture(user: User) {
        profileImage.image = user.image
        initialsLabel.isHidden = user.isInitialsHidden()
        initialsLabel.text = user.initials
        self.layer.cornerRadius = user.radius
        self.layer.borderColor = user.borderColor
        self.layer.borderWidth = user.borderWidth
    }
}
