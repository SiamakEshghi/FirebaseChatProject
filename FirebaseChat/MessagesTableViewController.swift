//
//  MessagesTableViewController.swift
//  FirebaseChat
//
//  Created by Asal Rostami on 2017-07-09.
//  Copyright © 2017 Joopooli. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Kingfisher


class MessagesTableViewController: UITableViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        perform(#selector(checkeduserislogedIn), with: nil, afterDelay: 0)
        observeUserMessages()
    }
    
    func observeUserMessages()  {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRefrence = Database.database().reference().child("messages").child(messageId)
            messageRefrence.observeSingleEvent(of: .value, with: { (snapshot) in
                let message = Message()
                
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    let fromId = dictionary["fromId"] as! String
                    let text = dictionary["text"] as! String
                    let timestampe = dictionary["timestamp"] as! String
                    let toId = dictionary["toId"] as! String
                    
                    message.fromId = fromId
                    message.text = text
                    message.timestamp = timestampe
                    message.toId = toId
                    
                    
                    
                    self.messageDictionary[message.chatPartnerId()!] = message
                    self.messages = Array(self.messageDictionary.values)
                    
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    
    
    @IBAction func writeMessage(_ sender: UIBarButtonItem) {
        handleNewMessage()
    }
    
    
    func handleNewMessage() {
        

        showAlert(text: "opened wite message page successfully")
    }
    
    func checkeduserislogedIn() {
        guard let uid = Auth.auth().currentUser?.uid
            else{
                handleLogout()
                return
        }
        
        Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let titleName = dictionary["name"] as? String
                
                self.displayTitle(name:titleName!)
            }
            
        }, withCancel: nil)
    }
    
    func displayTitle(name:String){
        let titleView = UILabel()
        titleView.text = name
        titleView.font = UIFont(name: "Snell Roundhand", size: 30)
        titleView.textColor = UIColor.magenta
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationBar.topItem?.titleView = titleView
        
    }
    
  
    func showChatControllerForUser(user:User){
        
        let chatLogcontroller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatLog") as! ChatLogViewController
        present(chatLogcontroller, animated: true, completion: nil)
        chatLogcontroller.user = user
    }
    
    
    @IBAction func logoutBtnTapped(_ sender: UIBarButtonItem) {
        handleLogout()
    }
    
    
    func handleLogout() {
        
        do{
            try  Auth.auth().signOut()
        }catch let logoutError{
            print(logoutError)
        }
        
        self.navigationBar.topItem?.title = ""
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView") as! LoginController
        present(loginVC, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! MessageCell
        
        let message = messages[indexPath.row]
        
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else{
            return
        }
        let ref = Database.database().reference().child("Users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else{
                return
            }
            
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
        
        
    }
    func showAlert(text:String)  {
        let alert = UIAlertController(title: "Attention", message: text, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
}
