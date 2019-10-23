//
//  UpdateCommentVC.swift
//  iTalk
//
//  Created by Mahmoud Elshakoushy on 10/23/19.
//  Copyright © 2019 Mahmoud Elshakoushy. All rights reserved.
//

import UIKit
import Firebase

class UpdateCommentVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var updateBtn: UIButton!
    
    //Variables
    var commentData : (comment: Comment, talk: Talk)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTxt.layer.cornerRadius = 10
        updateBtn.layer.cornerRadius = 10
        commentTxt.text = commentData.comment.commentTxt
    }
    
    
    @IBAction func updateBtnPressed(_ sender: Any) {
        Firestore.firestore().collection(TALKS_REF).document(commentData.talk.documentId).collection(COMMENTS_REF).document(commentData.comment.documentId)
            .updateData([COMMENT_TXT : commentTxt.text]) { (error) in
                if let error  = error {
                    debugPrint("Error editing comment: \(error.localizedDescription)")
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
        }
    }
}
