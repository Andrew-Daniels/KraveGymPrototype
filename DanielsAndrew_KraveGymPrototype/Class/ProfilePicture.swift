//
//  ProfilePicture.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/13/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import Foundation
import UIKit

class ProfilePicture {
    var radius: CGFloat = 35
    var borderColor = UIColor(displayP3Red: 33/255, green: 49/255, blue: 84/255, alpha: 1).cgColor
    var borderWidth: CGFloat = 4
    var tag = 0
    var image: UIImage?
    var initialsHidden = false
    var initials = ""
    var name = ""
    
    init(image: UIImage?) {
        self.image = image
        getHidden()
    }
    init(initials: String) {
        self.initials = initials
        getHidden()
    }
    
    private func getHidden() {
        if let _ = image {
            initialsHidden = true
        }
    }
}
