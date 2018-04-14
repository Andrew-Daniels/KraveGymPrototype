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
    
    func profilePicture(pp: ProfilePicture) {
        profileImage.image = pp.image
        initialsLabel.isHidden = pp.initialsHidden
        initialsLabel.text = pp.initials
        self.layer.cornerRadius = CGFloat(pp.radius)
        self.layer.borderColor = pp.borderColor
        self.layer.borderWidth = CGFloat(pp.borderWidth)
    }
    
    func getProfilePicture() -> ProfilePicture {
        let pp = ProfilePicture(image: profileImage.image)
        return pp
    }
}
