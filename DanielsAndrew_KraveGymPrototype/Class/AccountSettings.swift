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
import FirebaseStorage

class AccountSettings {
    
    var managedObjectContext: NSManagedObjectContext!
    var entityDescription: NSEntityDescription!
    var ref: DatabaseReference!
    let main = DispatchQueue.main
    var athleteCollectionView: UICollectionView!
    let serialQ = DispatchQueue(label: "SerialOne")
    var allAthleteImages = [String: UIImage!]()
    var classAthleteImages = [String: UIImage!]()
    
    init() {
        
    }
    
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
    
    func login(username: String, password: String, view: Login, rememberMe: Bool, completionHandler: @escaping (_ isResponse : Bool) -> Void) {
        ref.child("Accounts").child("Trainer").child(String(username)).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let accountPassword = value["Password"] as? String
                if password == accountPassword {
                    //Let trainer login
                    print("You've successfully logged in.")
                    if rememberMe {
                        //Save account information into CoreData
                        let account = NSManagedObject(entity: self.entityDescription, insertInto: self.managedObjectContext)
                        account.setValue(username, forKey: "username")
                        account.setValue(password, forKey: "password")
                        
                        do {
                            try self.managedObjectContext.save()
                        } catch {
                            print("Error saving context")
                        }
                    }
                    completionHandler(true)
                    return
                } else {
                    print("Incorrect password.")
                    completionHandler(false)
                    return
                }
            } else {
                let alert = UIAlertController(title: "An account with this phone number doesn't exist", message: "Please try registering for an account before logging in.", preferredStyle: .alert)
                let alertButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(alertButton)
                view.present(alert, animated: true, completion: {
                })
                completionHandler(false)
            }
        })
    }
    
    func getAllAthletes(completion: @escaping (_ isResponse : Bool, _ images : [User]) -> Void) {
        var athlete: User!
        var athletes: [User] = []
        var username = ""
        var firstName = ""
        var lastName = ""
        let userImage: UIImage! = nil
        ref.child("Accounts").child("Athlete").observe(.value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                for athleteData in value {
                    username = athleteData.key as! String
                    //I've got the username, now get the photo associated with it.
                    self.allAthleteImages[username] = userImage
                    for (label, name) in athleteData.value as! [String:String] {
                        if label == "First Name" {
                            firstName = name
                        } else {
                            lastName = name
                        }
                    }
                    athlete = User(firstName: firstName, lastName: lastName, username: username, image: nil)
                    if !athletes.contains(where: { (user) -> Bool in
                        user.username == athlete.username
                    }){
                        athletes.append(athlete)
                        completion(true, athletes)
                    }
                }
            } else {
                completion(false, [User]())
            }
        }
    }
    
    func getAllAthletePhotos(completion: @escaping (_ isResponse : Bool, _ images : [String: UIImage?]) -> Void) {
        for username in allAthleteImages.keys {
            let storageRef = Storage.storage().reference(withPath: "AthletePhotos/\(username).jpg")
            storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error)
                    completion(false, ["" : UIImage()])
                } else {
                    if let image = UIImage(data: data!) {
                        self.allAthleteImages[username] = image
                        completion(true, self.allAthleteImages)
                    }
                }
            }
        }
    }
    
    func getCurrentClassAthletes(completion: @escaping (_ isResponse : Bool, _ images : [User]) -> Void) {
        let currentDataAndTime = "041320180600"
        var athletes: [User] = []
        var athlete: User!
        var username = ""
        var firstName = ""
        var lastName = ""
        let userImage: UIImage! = nil
        ref.child("Class").child(currentDataAndTime).observe(.value) { (snapshot) in
            if let athletesData = snapshot.value as? NSDictionary {
                for usernames in athletesData {
                    username = usernames.key as! String
                    self.classAthleteImages[username] = userImage
                    for (label, name) in usernames.value as! [String : String] {
                        if label == "First Name" {
                            firstName = name
                        } else {
                            lastName = name
                        }
                    }
                    athlete = User(firstName: firstName, lastName: lastName, username: username, image: nil)
                    if !athletes.contains(where: { (user) -> Bool in
                        user.username == athlete.username
                    }){
                        athletes.append(athlete)
                        completion(true, athletes)
                    }
                }
            }
        }
    }
    
    func getClassAthletePhotos(completion: @escaping (_ isResponse : Bool, _ images : [String: UIImage?]) -> Void) {
        for username in classAthleteImages.keys {
            let storageRef = Storage.storage().reference(withPath: "AthletePhotos/\(username).jpg")
            storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error)
                    completion(false, ["" : UIImage()])
                } else {
                    if let image = UIImage(data: data!) {
                        self.classAthleteImages[username] = image
                        completion(true, self.classAthleteImages)
                    }
                }
            }
        }
    }
}
