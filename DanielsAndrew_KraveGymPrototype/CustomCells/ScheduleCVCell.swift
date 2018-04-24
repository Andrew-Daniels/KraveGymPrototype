//
//  ScheduleCVCell.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/23/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

class ScheduleCVCell: UICollectionViewCell {
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    
    @IBOutlet weak var cellSelectedView: UIView!
    @IBOutlet weak var dayAsNumberLabel: UILabel!
    var date: String!
}
