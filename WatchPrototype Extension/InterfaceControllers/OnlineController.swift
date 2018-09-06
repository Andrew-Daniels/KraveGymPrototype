//
//  OnlineController.swift
//  WatchPrototype Extension
//
//  Created by Andrew Daniels on 9/4/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import WatchKit
import Foundation


class OnlineController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print(context as! String)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
