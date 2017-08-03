//
//  ChatLogViewController.swift
//  FirebaseChat
//
//  Created by Asal Rostami on 2017-07-24.
//  Copyright © 2017 Joopooli. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChatLogViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var textFieldChatMessage: UITextField!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    var messages = [Message]()
    
    var user: User? {
        didSet{
            self.navigationBar.topItem?.title = user?.name
            observeMessages()
        }
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            let messageRef = Database.database().reference().child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictiionary = snapshot.value as? [String:AnyObject] else{return}
                let message = Message()
                message.setValuesForKeys(dictiionary)
                
                
                if message.chatPartnerId() == self.user?.id{
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        self.hideKeyboardWhenTappedAround()
    }
    
    
    @IBAction func cancellBtnTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendBtnTapped(_ sender: UIButton) {
        handleSend()
    }
    
    
    
    func handleSend() {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id
        let fromId = Auth.auth().currentUser?.uid
        
        
        let timestamp =  getCurrentTime()
        
        let values = ["text":textFieldChatMessage.text!,"toId":toId!,
                      "fromId":fromId,"timestamp":timestamp] as [String : AnyObject]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId!)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId:1])
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId!)
            recipientUserMessageRef.updateChildValues([messageId:1])
            
        }
    }
    
    func getCurrentTime() -> String {
        
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        
        // get the date time String from the date object
        return formatter.string(from: currentDateTime)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 88)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return messages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! messagesCollectionCell
        
        let uid = Auth.auth().currentUser?.uid
        
        let item = messages[indexPath.item]
        
        let ref = Database.database().reference().child("Users").child(item.fromId!)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                
                let name = dictionary["name"] as! String
                if item.fromId == uid {
                    cell.backgroundColor = UIColor.lightGray
                }else{
                    cell.backgroundColor = UIColor.purple
                }
                cell.labelMessages.text = "\(name) : \(item.text!)"
            }
            
        }, withCancel: nil)
        
        
        return cell
    }
    
    
}



