//
//  CoreDataStack.swift
//  CDStack
//
//  Created by Andrew Daniels on 3/19/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    //Our Notepad
    
    let context: NSManagedObjectContext!
    
    //The workhorse. This coordinates everything between our Objects, Contexts, and Persistent Store (our Hard Drive)
    let persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    //We model our data in the .xcdatamodel file in Xcode
    //We create entities and attributes etc.
    //This property will represent our entire .xcdatamodel file once setup
    let objModel: NSManagedObjectModel!
    
    //SQLite? XML? Binary? Reads/Write data in whatever format we chose.
    let store: NSPersistentStore?
    
    init() {
        //1. Setup our object model
        let xcDataModelURL = Bundle.main.url(forResource: "CoreData", withExtension: "momd")
        objModel = NSManagedObjectModel(contentsOf: xcDataModelURL!)
        
        //2. Use ObjModel to Setup StoreCoordinator
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: objModel)
        
        //3.Use StoreCoordinator to setup the ObjContext
        context = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        
        //4. Use StoreCoordinator to setup PersistantStore
        //a. Get the URL to our documents directory
        let directories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //b. create a new url file path in which to save this applications data by appending to the directory path.
        //This is the rough equivilant of saying "path = Documents/CDStack_Data"
        let storeURL = directories[0].appendingPathComponent("CDStack_Data")
        //c. create a dictionary of options.
        let storeOptions = [NSMigratePersistentStoresAutomaticallyOption: true]
        //d. set our store's value
        do {
            /* Sometimes you know a throwing function or method won't, in face, throw an error at runtime. On those occasions, you can write try! before the
                expression to disable error propogation and wrap the call in a runtime assertion that no error will be thrown. If an error actually is thrown. You'll get a runtime error.
             //That's fine with us. If the Core Data Setup isn't working, crashing will alert us to that fact.
             */
            store = try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: storeOptions)
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                //Replace this implementation with code to handle the error appropriately.
                //abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
