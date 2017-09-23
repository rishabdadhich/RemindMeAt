//
//  Utilities.swift
//  Remind Me At
//
//  Created by Rishabh on 28/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import Foundation
import MapKit

//---------------------
//MARK: Extensions
//---------------------
extension UIViewController {
    
    //Show alert with a title and message
    func showAlert(with title: String, andMessage message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension UINavigationController {
    
    private func doAfterAnimatingTransition(_ animated: Bool, completion: @escaping (() -> Void)) {
        
        if let coordinator = transitionCoordinator, animated {
            
            coordinator.animate(alongsideTransition: nil, completion: { _ in
                completion()
            })
            
        } else {
            OperationQueue.main.addOperation {
                completion()
            }
        }
    }
    
    func popToRootViewControllerAnimated(animated: Bool, completion: @escaping (() -> Void)) {
        popToRootViewController(animated: animated)
        doAfterAnimatingTransition(animated, completion: completion)
    }
}
