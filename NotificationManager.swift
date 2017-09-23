//
//  NotificationManager.swift
//  Remind Me At
//
//  Created by Rishabh on 28/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import Foundation
import CoreLocation
import  UserNotifications

struct NotificationManager {
    //Mark: variables
    
  /*  You use the shared UNUserNotificationCenter object to schedule notifications and manage notification-related behaviors in your app or app extension. The shared user notification center object supports both local or remote notifications */
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    //Mark: function
    func addLocationEvent(forReminder reminder: Reminder, whenleaving: Bool) -> UNLocationNotificationTrigger? {
        
  /*      A UNLocationNotificationTrigger object causes the delivery of a notification when the device enters or leaves a specified geographic region.
        */
        if let location = reminder.location, let identifier = reminder.identifier{
            
            let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = CLCircularRegion(center: center, radius: 50, identifier: identifier)
            
            switch whenleaving {
            case true:
                print("on exit")
                region.notifyOnExit = true
                region.notifyOnEntry = false
            case false:
                print("on entry")
                region.notifyOnExit = false
                region.notifyOnEntry = true
            }
            
            return UNLocationNotificationTrigger(region: region, repeats: false)
        }
        return nil
    }
    func sheduleNewNotification(withReminder reminder:Reminder,locationTrigger trigger:UNLocationNotificationTrigger?){
        
        if let text = reminder.text, let identifier = reminder.identifier, let notificationTrigger = trigger{
            
      /*      A UNMutableNotificationContent object contains the data associated with a notification. You use the properties of this class to specify the parameters of a local notification, such as whether the notification adds a badge to the app’s icon, plays a notification sound, or displays an alert. */
            
            let content = UNMutableNotificationContent()
            content.body = text
            content.sound = UNNotificationSound.default()
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: notificationTrigger)
            
            notificationCenter.add(request)
        }
    }
}
