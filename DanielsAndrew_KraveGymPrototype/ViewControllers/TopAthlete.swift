//
//  TopAthlete.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/19/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

class TopAthlete: UIViewController {

    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    var user: User!
    var account: AccountSettings!
    var allWorkoutCategories = [String: [String: String]]()
    var pageControl: UIPageControl!
    var pageControlIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        account.getSingleUserPhoto(username: user.username) { (completion, profileImage) in
            if completion {
                self.profileImageView.image = profileImage
                self.initialsLabel.isHidden = true
            }
        }
        account.getSingleUserFirstLastName(username: user.username) { (completion, firstName, lastName) in
            if completion {
                self.user.firstName = firstName
                self.user.lastName = lastName
                self.user.fullName = firstName + " " + lastName
                self.profilePicture(user: self.user)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func profilePicture(user: User) {
        profileImageView.image = user.image
        initialsLabel.isHidden = user.isInitialsHidden()
        user.initials = user.getInitials()
        initialsLabel.text = user.initials
        workoutNameLabel.text = user.workoutID
        scoreLabel.text = user.calculateWorkoutScore().description + " Reps"
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.borderColor = user.borderColor
        profileImageView.layer.borderWidth = user.borderWidth
        profileImageView.layer.masksToBounds = true
        getWorkoutName()
    }
    
    func getWorkoutName() {
        for category in allWorkoutCategories.keys {
            if let all = allWorkoutCategories[category] {
                for (workoutID, workoutName) in all {
                    if user.workoutID == workoutID {
                        workoutNameLabel.text = workoutName
                        return
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        pageControl.currentPage = pageControlIndex
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
