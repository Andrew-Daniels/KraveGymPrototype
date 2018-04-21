//
//  TopAthlete.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/20/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import Foundation
import UIKit

class TopAthleteUser {
    var username: String!
    var workoutID: String! = nil
    var workoutDetails: [Int]!
    var profileImage: UIImage! = nil
    
    init(username: String, workoutID: String, workoutDetails: [Int]) {
        self.username = username
        self.workoutID = workoutID
        self.workoutDetails = workoutDetails
    }
    
    func getPhoto(account: AccountSettings) {
        //Use username to grab photo if image == nil
        if profileImage == nil {
            //call function to get profile picture
        }
    }
    
    func calculateWorkoutScore() -> Int {
        var score = 0
        if let workoutDetails = workoutDetails {
            for set in workoutDetails {
                score = score + set
            }
        }
        return score
    }
}
