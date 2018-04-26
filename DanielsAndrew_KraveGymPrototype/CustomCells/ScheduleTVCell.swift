//
//  ScheduleTVCell.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/24/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

class ScheduleTVCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var assignButton: UIButton!
    var account: AccountSettings!
    var date: String!
    var alerts: UIAlertToVC!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func assignButton(_ sender: UIButton) {
        if sender.tag == 0 {
            alerts.presentAlert(title: "Are you sure?", message: "You want to assign this class to yourself?", date: date, time: timeLabel.text!)
        } else {
            account.unassignClass(date: date, time: timeLabel.text!)
        }
    }
}
