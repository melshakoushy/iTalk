//
//  Talk.swift
//  iTalk
//
//  Created by Mahmoud Elshakoushy on 10/20/19.
//  Copyright © 2019 Mahmoud Elshakoushy. All rights reserved.
//

import Foundation
import Firebase

class Talk {
    private(set) var username: String!
    private(set) var timestamp: Date!
    private(set) var talkTxt: String!
    private(set) var numComments: Int!
    private(set) var numLikes: Int!
    private(set) var documentId: String!
    private(set) var userId: String!
    
    init(username: String, timestamp: Date, talkTxt: String, numComments: Int, numLikes: Int, documentId: String, userId: String) {
        self.username = username
        self.timestamp = timestamp
        self.talkTxt = talkTxt
        self.numComments = numComments
        self.numLikes = numLikes
        self.documentId = documentId
        self.userId = userId
    }
    
    class func parseData(snapshot: QuerySnapshot?) -> [Talk]{
        var talks = [Talk]()
        guard let snap = snapshot else { return talks }
        for document in snap.documents {
            let data = document.data()
            let username = data[USERNAME] as? String ?? "Anonymous"
            let timestamp = data[TIMESTAMP] as? Date ?? Date()
            let numComments = data[NUM_COMMENTS] as? Int ?? 0
            let talkTxt = data[TALK_TXT] as? String ?? ""
            let numLikes = data[NUM_LIKES] as? Int ?? 0
            let documentId = document.documentID
            let userId = data[USER_ID] as? String ?? ""
            
            let newTalk = Talk(username: username, timestamp: timestamp, talkTxt: talkTxt, numComments: numComments, numLikes: numLikes, documentId: documentId, userId: userId)
            talks.append(newTalk)
        }
        
        return talks
        
    }

}
