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
    @IBOutlet weak var buttonView: UIView!
    
    var loginButton:FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loginButton)
        loginButton.center = buttonView.center
        
        loginButton.delegate = self
        
        if let token = FBSDKAccessToken.current(){
            fetchProfile()
        }


        // Do any additional setup after loading the view.
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
        print("completed login")
        fetchProfile()
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? UINavigationController!
        print("successfully loged in")
        self.present(controller!, animated: true, completion: nil)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
