//
//  WorkoutController.swift
//  WatchPrototype Extension
//
//  Created by Andrew Daniels on 9/4/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import WatchKit
import Foundation


import WatchKit
import Foundation
import CoreBluetooth

class WorkoutController: WKInterfaceController, CBPeripheralManagerDelegate {
    
    var bluetoothOn = false
    
    @IBOutlet var setTable: WKInterfaceTable!
    
    
    //MARK: - CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            bluetoothOn = true
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        setTable.setRowTypes(["normal", "update", "control"])
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        //nice
    }
}

