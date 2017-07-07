//
//  LoginController.swift
//  FirebaseChat
//
//  Created by Siamak Eshghi on 2017-06-25.
//  Copyright © 2017 Joopooli. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginController: UIViewController {
    
    var isSignIn:Bool = true
    
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var txtFieldName: UITextField!
    
    @IBOutlet weak var txtFieldEmail: UITextField!
    
    @IBOutlet weak var txtFieldPass: UITextField!

    @IBOutlet weak var imageViewProfile: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleImageView()
        txtFieldName.isHidden = true

        }

    
    func handleImageView()  {
        imageViewProfile.image = #imageLiteral(resourceName: "chat")
        imageViewProfile.isUserInteractionEnabled = true
        imageViewProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
    }
   
   
    
    @IBAction func signInSlectionChanged(_ sender: UISegmentedControl) {
        isSignIn = !isSignIn
        
        if isSignIn{
            signInBtn.setTitle("SignIn", for: .normal)
            txtFieldName.isHidden = true
        }else{
            signInBtn.setTitle("Register", for: .normal)
            txtFieldName.isHidden = false
        }
    }
    
    
    @IBAction func signInBtnAction(_ sender: UIButton) {
      handleRegister()
    }
    
    
    
    
}
