//
//  WorkoutLogTVCell.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/16/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

class WorkoutLogTVCell: UITableViewCell {

    @IBOutlet weak var setNumberLabel: UILabel!
    
    @IBOutlet weak var workoutTypeLabel: UILabel!
    @IBOutlet weak var repNumberTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
