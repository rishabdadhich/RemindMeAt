//
//  ReminderMasterTableViewController.swift
//  Remind Me At
//
//  Created by Rishabh on 30/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ReminderMasterTableViewController: UITableViewController {
    
    //Mark: variables
    
    // this contains singleton of core data manager
    let coreDataManager = CoreDataManager.sharedInstance
    // the selected reminder
    var selectedReminder : Reminder?
    // this contains the singleton of user notification
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set the fetech result controller delegate: the object that is notified when the fetched result changed
        coreDataManager.fetchedResultsController.delegate = self
        
        //Fetch the results from the database
        fetchResults()
        
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if there are reminder
        if let reminders = coreDataManager.fetchedResultsController.fetchedObjects?.count{
            // set rows no. equal to no. of reminder
            return reminders
        }else{
            return 1
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderTableViewCell
        // retrieve the reminder at position index path
        let reminder = coreDataManager.fetchedResultsController.object(at: indexPath)
        
        // Configure the cell...
        cell.configure(withReminder: reminder)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //retriving the selected reminder
        selectedReminder = coreDataManager.fetchedResultsController.object(at: indexPath)
        // perform segue to the DetailTableviewController
        performSegue(withIdentifier: "ReminderDetail", sender: self)
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //set the delete action
        let delete = UITableViewRowAction(style: .destructive, title: "Delete"){ action, indexPath in
            
            let reminder = self.coreDataManager.fetchedResultsController.object(at: indexPath)
            
            if let _ = reminder.location, let identifier = reminder.identifier {
                //remove the pending notification for the current reminder
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
            }
            // delete the reminder from the data base
            self.coreDataManager.deleteReminder(reminder: reminder)
            
        }
        // set the complete action
        let complete = UITableViewRowAction(style: .normal, title: "Completed"){ action, indexPath in
            let reminder = self.coreDataManager.fetchedResultsController.object(at: indexPath)
            reminder.isCompleted = true
            
            if let _ = reminder.location, let identifier = reminder.identifier {
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                self.notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
            }
            self.coreDataManager.saveContext()
        }
        //Set the incomplete action
        let incomplete = UITableViewRowAction(style: .normal, title: "Incompleted") { action, indexPath in
            
            let reminder = self.coreDataManager.fetchedResultsController.object(at: indexPath)
            reminder.isCompleted = false
            
            self.coreDataManager.saveContext()
        }
        
        let reminder = self.coreDataManager.fetchedResultsController.object(at: indexPath)
        //if the reminder is completed
        if reminder.isCompleted{
            //show
            return [delete, incomplete]
        }else{
            //show
            return [delete, complete]
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        //set bool
        UserDefaults.standard.set(false, forKey: "login")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "viewController") as UIViewController!
        
        self.present(controller!, animated: true, completion: nil)
        
    }
    @IBAction func createNewReminder(_ sender: Any) {
        //show an alert controller with a textfield and actions, it's used to set the title of the reminder:
        
        // creating the alert controller
        let alertController = UIAlertController(title: "New Reminder", message: nil, preferredStyle: .alert)
        
        // creating the save action
        let saveAction = UIAlertAction(title: "Save", style: .default){ saveAction in
            let textField = alertController.textFields![0] as UITextField
            //saving the reminder with text from textfield
            self.coreDataManager.saveReminder(withText: textField.text!, andLocation: nil)
            
        }
        
        // disabling the save action
        saveAction.isEnabled = false
        
        //adding a text field to the alert controller
        alertController.addTextField { (textField) in
            //setting the placeholder
            textField.placeholder = "Enter a reminder tittle"
            
            //Adding a notification observer for typing inside the textfield
            NotificationCenter.default.addObserver(forName: Notification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: { (notification) in
                
                //if the textfield is not empty
                if textField.text != "" {
                    //enabele the save action
                    saveAction.isEnabled = true
                }
            })
        }
        //creating the cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        //adding the actions
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        //presenting the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    ///Fetch the results from the CoreData Database
    func fetchResults() {
        
        do {
            //try to perform the fetch
            try coreDataManager.fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            showAlert(with: "Error", andMessage: "\(error.localizedDescription)")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReminderDetail" {
            
            let reminderDetailVc = segue.destination as! ReminderDetailTableViewController
            
            reminderDetailVc.reminder = selectedReminder
        }
        
    }
    
}
//---------------------
//MARK: Extension
//---------------------

extension ReminderMasterTableViewController: NSFetchedResultsControllerDelegate {
    
    //-------------------------------
    //MARK: Fetched Results Delegate
    //-------------------------------
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //if the content change, reload the data of the table.
        self.tableView.reloadData()
    }
}

