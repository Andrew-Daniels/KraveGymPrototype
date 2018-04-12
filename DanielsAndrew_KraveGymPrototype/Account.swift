//
//  Account.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/12/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import FirebaseDatabase

class AccountSettings {
    
    var managedObjectContext: NSManagedObjectContext!
    var entityDescription: NSEntityDescription!
    var ref: DatabaseReference!
    
    init(managedObjectContext: NSManagedObjectContext, entityDescription: NSEntityDescription, ref: DatabaseReference) {
        self.managedObjectContext = managedObjectContext
        self.entityDescription = entityDescription
        self.ref = ref
    }
    
    func createTrainerAccount(username: String, password: String, firstname: String, lastname: String, rememberMe: Bool) {
        ref.child("Accounts").child("Trainer").child(username).child("Password").setValue(password)
        ref.child("Accounts").child("Trainer").child(username).child("First Name").setValue(firstname)
        ref.child("Accounts").child("Trainer").child(username).child("Last Name").setValue(lastname)
        if rememberMe {
            //Save account information into CoreData
            let account = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
            account.setValue(username, forKey: "username")
            account.setValue(password, forKey: "password")
            
            do {
                try self.managedObjectContext.save()
            } catch {
                print("Error saving context")
            }
        }
    }
    func checkForExistingAccount(username: String, view: Register, completionHandler: @escaping (_ isResponse : Bool) -> Void) {
        ref.child("Accounts").child("Trainer").child(String(username)).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSDictionary {
                let alert = UIAlertController(title: "This phone number is already in use", message: "Please try logging in instead, or use a different phone number.", preferredStyle: .alert)
                let alertButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(alertButton)
                view.present(alert, animated: true, completion: {
                    view.passwordTextField.text = ""
                    view.confirmPasswordTextField.text = ""
                })
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        })
    }
    
}
