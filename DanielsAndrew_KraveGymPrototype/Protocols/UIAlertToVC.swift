//
//  UIAlertToVC.swift
//  
//
//  Created by Andrew Daniels on 4/26/18.
//

import Foundation

protocol UIAlertToVC {
    func presentCustomAlert(message: String, dayOfWeekTuple: (month: String, day: Int, year: Int), time: String, day: String)
}
