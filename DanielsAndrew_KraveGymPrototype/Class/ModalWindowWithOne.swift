//
//  ModalWindowWithOne.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 6/2/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

class ModalWindowWithOne: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var btn: UIButton!
    
    func setModalWindow(message: String, btnText: String) {
        self.message.text = message
        self.btn.setTitle(btnText, for: .normal)
        self.btn.layer.cornerRadius = 5
    }
}
