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
    
    @IBOutlet weak var classIndicator: UIView!
    @IBOutlet weak var cellSelectedView: UIView!
    @IBOutlet weak var dayAsNumberLabel: UILabel!
    
    var isClassAssigned = false
    var classIndicatorLoaded = false
    //var date: String!
    
    var dayOfWeekTuple: (month: String, day: Int, year: Int)!
    
    
    func getDate() -> String {
        if dayOfWeekTuple.day > 9 {
            return dayOfWeekTuple.month + "\(dayOfWeekTuple.day)" + "\(dayOfWeekTuple.year)"
        }
        return dayOfWeekTuple.month + "0\(dayOfWeekTuple.day)" + "\(dayOfWeekTuple.year)"
    }
}
