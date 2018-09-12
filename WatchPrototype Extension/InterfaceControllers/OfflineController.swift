//
//  OfflineController.swift
//  WatchPrototype Extension
//
//  Created by Andrew Daniels on 9/4/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import WatchKit
import WatchConnectivity

class OfflineController: WKInterfaceController, WCSessionDelegate {
    
    var watchSession: WCSession!
    var username: String!
    var sessionStarted = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        tryToLogin()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        tryToLogin()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func tryToLogin() {
        if let username = readUsernameFromDocDir() {
            self.username = username
        }
        if WCSession.isSupported() && !sessionStarted {
            sessionStarted = true
            self.watchSession = WCSession.default
            self.watchSession.delegate = self
            self.watchSession.activate()
        }
        if username != nil {
            pushController(withName: "OnlineController", context: username)
        }
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
    
    //MARK: WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let username = message["username"] as? String {
            self.username = username
            writeUsernameToDocDir()
        }
    }
    
    @IBAction func tryAgainBtn() {
        tryToLogin()
    }
}
