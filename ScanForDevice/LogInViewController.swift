//
//  LogInViewController.swift
//  ScanForDevice
//
//  Created by daire mc daid on 13/04/2018.
//  Copyright © 2018 daire mc daid. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {
    
 
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 10

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    @IBAction func loggedin(_ sender: Any) {
        
        // check if textfields are empty
        guard let email = emailText.text,
        email != "",
        let password = passwordText.text,
        password != ""
        
        else {
            let error = UIAlertController(title: "Uh Oh!", message: "Missing info!", preferredStyle: UIAlertControllerStyle.alert)
            
            let ok = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default)
            
            error.addAction(ok)
            
            self.present(error, animated: true, completion: nil)
            
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            
            //check if any errors in input
            guard error == nil else {
                
                let error = UIAlertController(title: "Oops!", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                
                let ok = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default)
                
                error.addAction(ok)
                
                self.present(error, animated: true, completion: nil)
                
                return
            }
            
            guard let user = user else { return }
            print(user.email ?? "Missing email")
            //self.performSegue(withIdentifier: "mainSegue", sender: self)
        })
    }
    
    
//    func onceLoggedIn() {
//        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//
//        let loggedin:ViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
//
//        self.present(loggedin, animated: true, completion: nil)
//    }
    
    @IBAction func createTapped(_ sender: Any) {
        
        // create the user 
        if let email = emailText.text, let password = passwordText.text {
            Auth.auth().createUser(withEmail: email, password: password, completion: {user, error in
                
                if let firebaseError = error {
                    
                    let error = UIAlertController(title: "Oops!", message: firebaseError.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let ok = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default)
                    
                    error.addAction(ok)
                    
                    self.present(error, animated: true, completion: nil)
                    print(firebaseError.localizedDescription)
                    return
                }
                
                let success = UIAlertController(title: "Success", message: "Account created successfully!", preferredStyle: UIAlertControllerStyle.alert)
                
                let ok = UIAlertAction(title: "Great", style: UIAlertActionStyle.default)
                
                success.addAction(ok)
                
                self.present(success, animated: true, completion: nil)
            })
        }
        
    }
    
    //exit keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        super.touchesBegan(touches, with: event)
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
