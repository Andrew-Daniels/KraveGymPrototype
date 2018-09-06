//
//  OfflineController.swift
//  WatchPrototype Extension
//
//  Created by Andrew Daniels on 9/4/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import WatchKit
import CoreBluetooth
import WatchConnectivity

class OfflineController: WKInterfaceController, CBPeripheralManagerDelegate, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let username = message["username"] as? String {
            self.username = username
            writeUsernameToDocDir()
        }
    }
    
    var bluetoothOn = false
    var peripheralManager: CBPeripheralManager!
    var transferCharacteristic: CBMutableCharacteristic!
    var central: CBCentral!
    var servCBUUID = "06B280C1-429D-5D87-810E-00D44B506317"
    var charCBUUID = "1D513797-VA7C-5008-A692-3335A1244577"
    var watchSession: WCSession!
    var username: String!
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn && username != nil {
            bluetoothOn = true
            pushController(withName: "OnlineController", context: username)
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        peripheralManager = CBPeripheralManager.init()
        peripheralManager.delegate = self
        // Configure interface objects here.
        if let username = readUsernameFromDocDir() {
            self.username = username
        }
        if WCSession.isSupported() {
            self.watchSession = WCSession.default
            self.watchSession.delegate = self
            self.watchSession.activate()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func writeUsernameToDocDir() {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let url = urls.first else {
            return
        }
        
        // The types that can be stored in this dictionary are the same as what NSUserDefaults can do
        let preferences = [ "username" :  username ]
        
        if let data = try? PropertyListSerialization.data(fromPropertyList: preferences, format: .xml, options: 1) {
            do {
                try data.write(to: url.appendingPathComponent("mypreferences.plist"))
            } catch {
                print("Failed to write")
            }
        }
    }
    func readUsernameFromDocDir() -> String? {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let url = urls.first else {
            return nil
        }
        if let input = try? Data(contentsOf: url.appendingPathComponent("mypreferences.plist")),
            let dictionary = try? PropertyListSerialization.propertyList(from: input, options: .mutableContainersAndLeaves, format: nil),
            let d = dictionary as? [String : String],
            let value = d["username"] {
            return value
        }
        return nil
    }
    
}
