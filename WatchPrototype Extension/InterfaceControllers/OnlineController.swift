//
//  OnlineController.swift
//  WatchPrototype Extension
//
//  Created by Andrew Daniels on 9/4/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import WatchKit
import Foundation
import CoreBluetooth

class OnlineController: WKInterfaceController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet var instructorLabel: WKInterfaceLabel!
    
    var isBluetoothOn: Bool = true
    var centralManager: CBCentralManager!
    var trainerPeripheral: CBPeripheral!
    var bluetoothOn = false
    var peripheralManager: CBPeripheralManager!
    var transferCharacteristic: CBMutableCharacteristic!
    var central: CBCentral!
    var servCBUUID = CBUUID.init(string: "06B280C1-419D-4D87-810E-00D88B506717")
    var charCBUUID = CBUUID.init(string: "06B280C1-419D-4D87-810E-00D88B506718")
    var username: String!
    var BEAN_NAME = "KraveGymPeripheral"

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let username = context as? String {
            self.username = username
        }
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
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
    
    //MARK: CBCentralManagerDelegate
    //pushController(withName: "OnlineController", context: username)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            isBluetoothOn = false
            print("Bluetooth is off")
            return
        } else {
            isBluetoothOn = true
            if username != nil {
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary)
            .object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        if device?.contains(BEAN_NAME) == true {
            self.centralManager.stopScan()
            self.instructorLabel.setText("Instructor is online. Wait for class to start.")
            self.trainerPeripheral = peripheral
            self.trainerPeripheral.delegate = self
            
            centralManager.connect(peripheral, options: nil)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }

}
