//
//  User.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/13/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import Foundation
import UIKit

class User {
    var firstName: String!
    var lastName: String!
    var fullName: String!
    var initials: String!
    var username: String!
    var image: UIImage!
    
    init(firstName: String, lastName: String, username: String, image: UIImage?) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.fullName = firstName + " " + lastName
        self.image = image
        self.initials = getInitials()
    }
    
    private func getInitials() -> String {
        var names = fullName.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        if names.count == 3 {
            if let first = names[0].first, let last = names[2].first {
                initials = "\(first)\(last)"
            }
        } else if names.count == 2 {
            if let first = names[0].first, let last = names[1].first {
                initials = "\(first)\(last)"
            }
        } else if names.count == 1 {
            if let first = names[0].first {
                initials = "\(first)"
            }
        }
        return initials
    }
}
