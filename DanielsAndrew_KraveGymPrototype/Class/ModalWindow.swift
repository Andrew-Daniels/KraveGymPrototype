//
//  ModalWindow.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 6/2/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

class ModalWindowWithTwo: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var positiveButton: UIButton!
    
    @IBOutlet weak var bottomMessage: UILabel!
    @IBOutlet weak var topMessage: UILabel!
    
    func setModalWindow(topMessage: String, bottomMessage: String, negBtnText: String, posBtnText: String) {
        self.topMessage.text = topMessage
        self.bottomMessage.text = bottomMessage
        self.positiveButton.setTitle(posBtnText, for: .normal)
        self.negativeButton.setTitle(negBtnText, for: .normal)
        self.negativeButton.layer.cornerRadius = 5
    }
}
