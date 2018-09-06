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
    var account: AccountWork!
    var date: String!
    var alerts: UIAlertToVC!
    var dayOfWeekTuple: (month: String, day: Int, year: Int)!
    var dayOfWeek: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getDate() -> String {
        if dayOfWeekTuple.day > 9 {
            return dayOfWeekTuple.month + "\(dayOfWeekTuple.day)" + "\(dayOfWeekTuple.year)"
        }
        return dayOfWeekTuple.month + "0\(dayOfWeekTuple.day)" + "\(dayOfWeekTuple.year)"
    }

    @IBAction func assignButton(_ sender: UIButton) {
        if sender.tag == 0 {
            alerts.presentCustomAlert(message: "Are you sure you want to instruct this class?",
                                      dayOfWeekTuple: dayOfWeekTuple,
                                      time: timeLabel.text!,
                                      day: dayOfWeek)
        } else {
            account.unassignClass(date: getDate(), time: timeLabel.text!)
        }
    }
}
