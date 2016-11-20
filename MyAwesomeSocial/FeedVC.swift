//
//  FeedVC.swift
//  MyAwesomeSocial
//
//  Created by Lars Björk on 2016-11-20.
//  Copyright © 2016 Lars Björk. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signOutTapped(_ sender: UIButton) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "gotoSignIn", sender: nil)
    }
   

}
