//
//  FacebookViewController.swift
//  Remind Me At
//
//  Created by Rishabh on 03/07/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import UIKit

class FacebookViewController: UIViewController,FBSDKLoginButtonDelegate {
    
    //Mark:outlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var namelbl: UILabel!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FBSDKAccessToken.current() == nil {
            print("user is not logged in")
        }else{
            print("user logged in")
        }
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email"]
        
        if let token = FBSDKAccessToken.current(){
            fetchProfile()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if (FBSDKAccessToken.current() != nil) {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? UINavigationController!
            print("successfully loged in")
            self.present(controller!, animated: true, completion: nil)
            
        }
        
    }
    //check for net connection
    override func viewDidAppear(_ animated: Bool) {
        // ViewControllers view ist fully loaded and could present further ViewController
        //Here you could do any other UI operations
        if Reachability.isConnectedToNetwork() == true
        {
            print("Connected")
        }
        else
        {
            let controller = UIAlertController(title: "No Internet Detected", message: "This app requires an Internet connection", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            controller.addAction(ok)
            controller.addAction(cancel)
            
            present(controller, animated: true, completion: nil)
        }
        
    }
    
    func fetchProfile(){
        print("fetch profile")
        let parameters = ["fields" : "email, first_name, last_name, id, gender, picture.type(large)"]
        
        FBSDKGraphRequest(graphPath: "me", parameters: parameters)
            .start(completionHandler:  {
                (connection, result, error) in
                
                guard let result = result as? NSDictionary else{
                    print("no result")
                    return
                }
                guard let email = result["email"] as? String else{
                    print("no email found")
                    return
                }
                print(email)
                guard let fname = result["first_name"] as? String else{
                    print("first name not found")
                    return
                }
                print(fname)
                guard let lname = result["last_name"] as? String else{
                    print("last name not found")
                    return
                }
                self.namelbl.text = fname + " " + lname
                guard let photo = result["picture"] as? NSDictionary else{
                    print("no photo dict found")
                    return
                }
                guard let data = photo["data"] as? NSDictionary else{
                    print("no data found")
                    return
                }
                guard let url = data["url"] as? String else{
                    print("no url")
                    return
                }
                print(url)
                
                // create url
                let imageURL = URL(string: url)!
                
                // create network request
                let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                    
                    if error == nil {
                        
                        // create image
                        let downloadedImage = UIImage(data: data!)
                        performUIUpdatesOnMain {
                            self.imgView.image = downloadedImage
                        }
                        
                    }
                    else{
                        print(error!)
                    }
                    
                }
                task.resume()
                
            })
        
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if let userToken = result.token{
            let token:FBSDKAccessToken = result.token
            print("token = \(FBSDKAccessToken.current().tokenString)")
            print("completed login")
            
            fetchProfile()
            //set bool for userdefault
            UserDefaults.standard.set(true, forKey: "login")
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? UINavigationController!
            print("successfully loged in")
            self.present(controller!, animated: true, completion: nil)
        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
}
