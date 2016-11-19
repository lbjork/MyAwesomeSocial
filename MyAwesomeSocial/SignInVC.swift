//
//  ViewController.swift
//  MyAwesomeSocial
//
//  Created by Lars Björk on 2016-11-14.
//  Copyright © 2016 Lars Björk. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
        let facebooklogin = FBSDKLoginManager()

        facebooklogin.logIn(withReadPermissions: ["email"], from: self, handler: { (result, error) in
            if error != nil {
                print("LARS: Something went wrong with facebook authentication \(error)")
            } else if result?.isCancelled == true {
                print("LARS: User cancelled the facebook login")
            } else {
                print("LARS: Authentication sucessfull")
                let credentials = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credentials)
            }
        }
        )

    }

    func firebaseAuth(_ credentials: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("LARS: Unable to authenticate with firebase: \(error)")
            }
            else {
                print("LARS: Successfully authenticated with Firebase")
            }
        })
    }

}

