//
//  CoreDataManager.swift
//  Remind Me At
//
//  Created by Rishabh on 28/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation



public class CoreDataManager {
    
    ///Shared instance, *Singleton Design Pattern*
    static let sharedInstance = CoreDataManager()
    
    //----------------------
    //MARK: Core Data Stack
    //----------------------
    
    ///This contains the *Core Data Stack*
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Remind_Me_At")
        container.loadPersistentStores(completionHandler: { storeDiscriptor, error in
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    ///This contains the *Managed Object Context*
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        return self.persistentContainer.viewContext
    }()
    
    ///This contains the **Controller** for the *Fetched Results*
    lazy var fetchedResultsController: NSFetchedResultsController<Reminder> = {
        
        //Creating the request
        let fetchRequest: NSFetchRequest = Reminder.fetchRequest()
        //creating the sort descriptor: ordered by date
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        //adding hte sort descriptor to the request
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //Creating the controller with: the request and the menaged context.
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    //----------------------
    //MARK: Saving
    //----------------------
    
    ///This func **save** the *Menaged Object Context*
    func saveContext() {
        
        //If the menaged object context has any changes
        if self.managedObjectContext.hasChanges {
            
            do {
                //try to save
                try self.managedObjectContext.save()
                print("Save successfull")
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            //else if it does not have any changes
        } else {
            print("Does not have changes")
        }
    }
    
    /**
     Save the reminder.
     - Parameter text: the text for the reminder.
     - Parameter location: the location of the reminder.
     */
    func saveReminder(withText text: String, andLocation location: CLLocation?) {
        //creating a new reminder
        let reminder = Reminder(entity: Reminder.entity(), insertInto: self.managedObjectContext)
        //Editing the reminder
        reminder.text = text
        reminder.date = NSDate()
        reminder.identifier = String(describing: Date())
        
        //if the location is not nil, save the location
        if let location = location {
            reminder.location = self.saveLocation(location: location)
        }
        
        self.saveContext()
    }
    
    ///Save the location
    func saveLocation(location: CLLocation) -> Location {
        
        //creating a new location
        let loc = Location(entity: Reminder.entity(), insertInto: self.managedObjectContext)
        
        loc.latitude = location.coordinate.latitude
        loc.longitude = location.coordinate.longitude
        
        return loc
    }
    
    //----------------------
    //MARK: Deleting
    //----------------------
    
    /**
     Delete the reminder
     - Parameter reminder: the reminder to delete
     */
    func deleteReminder(reminder: Reminder) {
        
        //deleting..
        managedObjectContext.delete(reminder)
        //saving::
        self.saveContext()
    }
    
    
}
