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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FancyField!
    @IBOutlet weak var likeImg: UIImage!


    var imagePicker: UIImagePickerController!
    var posts = [Post]()
   // static var imageCache: Cache<NSString, UIImage> = Cache()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in

            self.posts = []

            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })

        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {


            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
                return cell
            } else {
                cell.configureCell(post: post)
                return cell
            }
        } else {
            return PostCell()
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("LARS: A valid image was not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, AnyObject> = ["caption": captionField.text as AnyObject,"imageUrl": imgUrl as AnyObject, "likes": 0 as AnyObject]

        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)

        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")

        tableView.reloadData()
    }

    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func postBtnTapped(_ sender: Any) {
        guard let caption = captionField.text, caption != "" else {
            print("LARS: Caption field is empty")
            return
        }
        guard let img = imageAdd.image, imageSelected == true else {
            print("LARS: An image must be selected")
            return
        }

        if let imgData = UIImageJPEGRepresentation(img, 0.2) {

            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"

            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) {(metadata, error) in
                if error != nil {
                    print("LARS: unable to upload image to firebase storage")
                } else {
                    print("LARS: Successfully uploaded image to firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                         self.postToFirebase(imgUrl: url)
                    }


                }
            }
        }
    }


    @IBAction func signOutTapped(_ sender: UIButton) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "gotoSignIn", sender: nil)
    }
    
    
    
}
