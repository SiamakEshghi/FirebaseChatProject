//
//  Logincontroller+.swift
//  FirebaseChat
//
//  Created by Siamak Eshghi on 2017-06-30.
//  Copyright © 2017 Joopooli. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

extension LoginController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    
    //Mark: -Registering
    
    func handleRegister() {
        guard let email = txtFieldEmail.text
            ,let pass = txtFieldPass.text,
            let name = txtFieldName.text else{
                print("Fiil all fields")
                return
        }
        if isSignIn {
            //Sign in the user with Firebase
            Auth.auth().signIn(withEmail: email, password: pass){ (user,error) in
                if error != nil{
                    self.showAlert(text: (error?.localizedDescription)!)
                    print(error!)
                    return
                }else{
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }else{
            //Register the user with Firebase
            Auth.auth().createUser(withEmail: email, password: pass){(user,error) in
                if error != nil { print(error!)
                self.showAlert(text: (error?.localizedDescription)!)
                    return
                }else{
                    
                    guard let uid = user?.uid else{
                        return
                    }
                    
                    //successffully register
                    let imageName = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child("Profile_Images").child("\(imageName).jpg")
                    
                    if let profileImage = self.imageViewProfile.image,let uploadedData = UIImageJPEGRepresentation(profileImage, 0.1){
                        
                        //if let uploadedData = UIImagePNGRepresentation(self.imageViewProfile.image!)
                        
                        storageRef.putData(uploadedData, metadata: nil, completion: { (metadata, error) in
                            if error != nil{
                                print(error!)
                                return
                            }
                            
                            if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                                let values = ["name":name,"email":email,"ProfileImageUrl":profileImageUrl]
                                
                                self.registerUserIntoFirebaseDatabase(uid: uid, values: values as [String : AnyObject])
                                
                            }
                            
                        })
                    }
                    
                    
                }
                
            }
            
        }
    }
    
    private func registerUserIntoFirebaseDatabase(uid: String,values: [String:AnyObject]){
        var ref : DatabaseReference!
        ref = Database.database().reference()
        let usersRef = ref.child("Users").child(uid)
        
        usersRef.updateChildValues(values){(err,ref) in
            if err != nil {
                print(err!)
                return
            }
            print("Saved user successfully into Firebase")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Mark: - Selecting fill by piker
    func handleSelectProfileImage()  {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPiker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            selectedImageFromPiker = editedImage
        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectedImageFromPiker = originalImage}
        
        if let selectedImage = selectedImageFromPiker{
            
            imageViewProfile.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel picker")
        dismiss(animated: true, completion: nil)
    }
    
    func showAlert(text:String)  {
        let alert = UIAlertController(title: "Attention", message: text, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
