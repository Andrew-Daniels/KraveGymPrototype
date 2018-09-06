//
//  ModalWindowWithDate.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 6/5/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

class ModalWindowWithDate: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var positiveButton: UIButton!
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayAsNumberView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dayAsNumberLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var topMessage: UILabel!
    
    var date: String!
    
    func setModalWindow(topMessage: String, dayOfWeekTuple: (month: String, day: Int, year: Int), time: String, day: String, negBtnText: String, posBtnText: String, centerX: CGFloat, centerY: CGFloat) {
        self.topMessage.text = topMessage
        self.positiveButton.setTitle(posBtnText, for: .normal)
        self.negativeButton.setTitle(negBtnText, for: .normal)
        self.negativeButton.layer.cornerRadius = 5
        self.positiveButton.layer.cornerRadius = 5
        self.center.x = centerX
        self.center.y = centerY
        self.alpha = 0
        self.layer.cornerRadius = 15
        self.monthLabel.text = dayOfWeekTuple.month
        self.dayAsNumberLabel.text = dayOfWeekTuple.day.description
        self.timeLabel.text = time
        self.dayAsNumberView.layer.cornerRadius = dayAsNumberView.frame.height / 2
        self.dayLabel.text = day
    }
}
