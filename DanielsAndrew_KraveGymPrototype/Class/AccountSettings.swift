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
    var allAthleteImages = [String: UIImage?]()
    var classAthleteImages = [String: UIImage?]()
    var workouts: [String: [String:String]] = [:]
    var username: String!
    
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
                let subview = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
                subview.backgroundColor = UIColor(displayP3Red: 33/255, green: 49/255, blue: 84/255, alpha: 1)
                view.present(alert, animated: true, completion: {
                    view.passwordTextField.text = ""
                    view.confirmPasswordTextField.text = ""
                })
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        })
    }
    
    func login(username: String, password: String, view: Login, rememberMe: Bool, completionHandler: @escaping (_ isResponse : Bool) -> Void) {
        self.username = username
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
        let userImage: UIImage? = nil
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
                    }
                }
                completion(true, athletes)
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
        let userImage: UIImage? = nil
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
                    }
                }
                completion(true, athletes)
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
    
    func saveRememberedAccount(username: String, password: String) {
        deleteRememberedAccount()
        let rememberedAccount = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
        rememberedAccount.setValue(username, forKey: "username")
        rememberedAccount.setValue(password, forKey: "password")
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Error saving context")
        }
    }
    
    func retrieveRememberedAccount() -> (username: String, password: String) {
        var uname = ""
        var pword = ""
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Account")
        do { let accounts = try managedObjectContext.fetch(fetchRequest)
            for account in accounts {
                uname = account.value(forKey: "username") as! String
                pword = account.value(forKey: "password") as! String
            }
        }
        catch {
            print("Error fetching Core Data")
        }
        return (username: uname, password: pword)
    }
    
    func deleteRememberedAccount() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Account")
        do { let accounts = try managedObjectContext.fetch(fetchRequest)
            for account in accounts {
                managedObjectContext.delete(account)
            }
        }
        catch {
            print("Error fetching Core Data")
        }
    }
    
    func getWorkoutCategories(completion: @escaping (_ completion : Bool, _ workoutCategories : [String: [String:String]]) -> Void) {
        ref.child("Workouts").observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: [String:String]] {
                self.workouts = dictionary
                completion(true, self.workouts)
            }
        }
    }
    
    func saveWorkout(username: String, date: String, workoutID: String, workoutData: [String:String]) {
        for (set, rep) in workoutData {
            ref.child("Logged Workouts").child("\(username)").child(date).child(workoutID).child(set).setValue(rep)
        }
    }
    func undoSavedWorkout(username: String, date: String, workoutID: String){
        ref.child("Logged Workouts").child("\(username)").child(date).child(workoutID).removeValue()
    }
    
    func getAllAthleteWorkoutData(completion: @escaping (_ completion : Bool, _ allAthletesWorkoutDataArray : [User]) -> Void) {
        var allAthletesWorkoutDataArray = [User]()
        var tempArray = [User]()
        ref.child("Logged Workouts").observe(.value) { (snapshot) in
            tempArray = allAthletesWorkoutDataArray
            allAthletesWorkoutDataArray.removeAll()
            if let value = snapshot.value as? NSDictionary {
                //print(value)
                for values in value {
                    //print(values.key) // Phone number here
                    if let anotherValue = values.value as? NSDictionary {
                        //print(anotherValue)
                        for aValue in anotherValue {
                            //print(aValue.key) // Date here
                            if let bValue = aValue.value as? NSDictionary {
                                //print(bValue)
                                for cValue in bValue {
                                    //print(cValue.key) //WorkoutID
                                    if let dValue = cValue.value as? [String?] {
                                        var reps = [Int]()
                                        for rep in dValue {
                                            if let rep = rep {
                                                if let rep = Int(rep) {
                                                    reps.append(rep)
                                                }
                                            }
                                        }
                                        let topAthlete = User(username: values.key as! String, workoutID: cValue.key as! String, workoutDetails: reps)
                                        allAthletesWorkoutDataArray.append(topAthlete)
                                    }
                                }
                            }
                        }
                    }
                }
                for user in allAthletesWorkoutDataArray {
                    if !tempArray.contains(where: { (tempUser) -> Bool in
                        if tempUser === user {
                            return true
                        } else {
                            return false
                        }
                    }) {
                        //do completion here
                        completion(true, allAthletesWorkoutDataArray)
                    }
                }
            }
        }
    }
    
    func getSingleUserPhoto(username: String, completion: @escaping (_ isResponse : Bool, _ image : UIImage?) -> Void) {
        let storageRef = Storage.storage().reference(withPath: "AthletePhotos/\(username).jpg")
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
                completion(false, UIImage())
            } else {
                if let image = UIImage(data: data!) {
                    completion(true, image)
                }
            }
        }
    }
    func getSingleUserFirstLastName(username: String, completion: @escaping (_ isResponse : Bool, _ firstName : String, _ lastName: String) -> Void) {
        ref.child("Accounts").child("Athlete").child("\(username)").observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String : String] {
                var firstName = ""
                var lastName = ""
                for (nameLabel, name) in value {
                    if nameLabel == "First Name" {
                        firstName = name
                    } else {
                        lastName = name
                    }
                }
                completion(true, firstName, lastName)
            }
        }
    }
    func getAllClasses(date: String, completion: @escaping (_ isResponse : Bool, _ scheduleAsArray : [String: String]) -> Void) {
        //date format should be "04242018"
        ref.child("Schedule").child(date).observe(.value) { (snapshot) in
            var scheduleAsArray = [String: String]()
            if let value = snapshot.value as? NSDictionary {
                for (time, username) in value {
                    scheduleAsArray[String(describing: time)] = String(describing: username)
                }
                completion(true, scheduleAsArray)
            } else {
                completion(false, scheduleAsArray)
            }
        }
    }
    func assignClass(date: String, time: String) {
        ref.child("Schedule").child(date).child(time).setValue(username)
    }
    func unassignClass(date: String, time: String) {
        ref.child("Schedule").child(date).child(time).removeValue()
    }
}
