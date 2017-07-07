//
//  Message.swift
//  FirebaseChat
//
//  Created by Siamak Eshghi on 2017-07-02.
//  Copyright © 2017 Joopooli. All rights reserved.
//

import UIKit
import FirebaseAuth

class Message: NSObject {

    var fromId: String?
    var text: String?
    var timestamp: String?
    var toId: String?
    
    
    
    func chatPartnerId() -> String? {
        
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
