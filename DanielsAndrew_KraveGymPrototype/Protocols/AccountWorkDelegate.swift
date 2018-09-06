//
//  AccountWorkDelegate.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 6/25/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import Foundation
import UIKit

protocol AccountWorkDelegate {

    func createTrainerAccount(username: String, password: String, firstname: String, lastname: String, rememberMe: Bool)
    func getCurrentClassAthletes(completion: @escaping (_ isResponse : Bool, _ images : [User]) -> Void)
    func checkForExistingAccount(username: String, view: Register, completionHandler: @escaping (_ isResponse : Bool) -> Void)
    func login(username: String, password: String, view: Login, rememberMe: Bool, completionHandler: @escaping (_ isResponse : Bool) -> Void)
    func getAllAthletes(completion: @escaping (_ isResponse : Bool, _ images : [User]) -> Void)
    func getAllAthletePhotos(completion: @escaping (_ isResponse : Bool, _ images : [String: UIImage?]) -> Void)
    func newGetAthletePhoto(username: String, completion: @escaping (_ isResponse : Bool, _ images : UIImage?) -> Void)
    func getClassAthletePhotos(completion: @escaping (_ isResponse : Bool, _ images : [String: UIImage?]) -> Void)
    func getWorkoutCategories(completion: @escaping (_ completion : Bool, _ workoutCategories : [String: [String:String]]) -> Void)
    func saveWorkout(username: String, date: String, workoutID: String, workoutData: [String:String])
    func undoSavedWorkout(username: String, date: String, workoutID: String)
    func getAllAthleteWorkoutData(completion: @escaping (_ completion : Bool, _ allAthletesWorkoutDataArray : [User]) -> Void)
    func getSingleUserPhoto(username: String, completion: @escaping (_ isResponse : Bool, _ image : UIImage?) -> Void)
    func getSingleUserFirstLastName(username: String, completion: @escaping (_ isResponse : Bool, _ firstName : String, _ lastName: String) -> Void)
    func getAllClasses(date: String, completion: @escaping (_ isResponse : Bool, _ date: String, _ scheduleAsArray : [String: String]) -> Void)
    func determineClassIndicator(dateAndIndex: (date: String, rowIndex: Int), completion: @escaping (_ isResponse : Bool, _ isClassAssigned: Bool) -> Void)
    func assignClass(date: String, time: String, completed: @escaping (_ isResponse : Bool) -> ())
    func unassignClass(date: String, time: String)
}
