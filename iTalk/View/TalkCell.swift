//
//  TalkCell.swift
//  iTalk
//
//  Created by Mahmoud Elshakoushy on 10/20/19.
//  Copyright © 2019 Mahmoud Elshakoushy. All rights reserved.
//

import UIKit
import Firebase

class TalkCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var talkTxtLbl: UILabel!
    @IBOutlet weak var commentsLbl: UILabel!
    
    // Variables
    private var talk:Talk!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
    }
    
    @objc func likeTapped() {
        Firestore.firestore().collection(TALKS_REF).document(talk.documentId)
            .setData([NUM_LIKES : talk.numLikes + 1], merge: true)
    }
    
    func configureCell(talk: Talk) {
        self.talk = talk
        userNameLbl.text = talk.username
        talkTxtLbl.text = talk.talkTxt
        likesLbl.text = String(talk.numLikes)
        commentsLbl.text = String(talk.numComments)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: talk.timestamp)
        timestampLbl.text = timestamp
    }

}
