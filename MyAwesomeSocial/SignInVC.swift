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
import SwiftKeychainWrapper

class SignInVC: UIViewController {


    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!


    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
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
                if let user = user {
                    self.completeSingIn(id: user.uid)
                }

            }
        })
    }


    @IBAction func singInTapped(_ sender: Any) {
        if let email = emailField.text, let pwd = pwdField.text {

            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("Email user authenticated with firebase")
                    if let user = user {
                        self.completeSingIn(id: user.uid)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("LARS: Unable to authenticate with firebase using email")
                        } else {
                            print("Successfully authenticated with firebase")
                            if let user = user {
                                self.completeSingIn(id: user.uid)
                            }

                        }
                    })
                }
            })
        }
    }

    func completeSingIn(id: String) {
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("LARS: Data saved to Keychain: \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}

