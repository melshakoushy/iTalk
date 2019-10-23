//
//  CommentsVC.swift
//  iTalk
//
//  Created by Mahmoud Elshakoushy on 10/22/19.
//  Copyright © 2019 Mahmoud Elshakoushy. All rights reserved.
//

import UIKit
import Firebase

class CommentsVC: UIViewController {
   
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCommentTxtField: UITextField!
    @IBOutlet weak var keyboardView: UIView!
    
    // Variables
    var talk: Talk!
    var comments = [Comment]()
    var talkRef: DocumentReference!
    let firestore = Firestore.firestore()
    var username: String!
    var commentListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        talkRef = firestore.collection(TALKS_REF).document(talk.documentId)
        if let name = Auth.auth().currentUser?.displayName {
            username = name
        }
        self.view.bindToKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        commentListener = firestore.collection(TALKS_REF).document(self.talk.documentId).collection(COMMENTS_REF)
            .order(by: TIMESTAMP, descending: false)
            .addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else {
                debugPrint("Error fetching comments: \(error!)")
                return
            }
            self.comments.removeAll()
            self.comments = Comment.parseData(snapshot: snapshot)
            self.tableView.reloadData()
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        commentListener.remove()
    }

    @IBAction func addCommentPressed(_ sender: Any) {
        guard let commentTxt = addCommentTxtField.text else { return }
        
        firestore.runTransaction({ (transaction, errorPointer) -> Any? in
            
            let talkDocument: DocumentSnapshot
            
            do {
                try talkDocument = transaction.getDocument(Firestore.firestore().collection(TALKS_REF).document(self.talk.documentId))
            } catch let error as NSError {
                debugPrint("Fetch Error: \(error.localizedDescription)")
                return nil
            }
            guard let oldNumComments = talkDocument.data()?[NUM_COMMENTS] as? Int else { return nil }
            
            transaction.updateData([NUM_COMMENTS : oldNumComments + 1 ], forDocument: self.talkRef)
            
            let newCommentRef = self.firestore.collection(TALKS_REF).document(self.talk.documentId).collection(COMMENTS_REF).document()
            
            transaction.setData([
                COMMENT_TXT : commentTxt,
                TIMESTAMP : FieldValue.serverTimestamp(),
                USERNAME : self.username,
                USER_ID : Auth.auth().currentUser?.uid ?? ""
                ], forDocument: newCommentRef)
            
            return nil
        }) { (object, error) in
            if let error =  error {
                debugPrint("Transaction Failed: \(error)")
            } else {
                self.addCommentTxtField.text = ""
                self.addCommentTxtField.resignFirstResponder()
            }
        }
        
    }
}

extension CommentsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentCell {
            cell.configureCell(comment: comments[indexPath.row], delegate: self)
            return cell
        }
        return UITableViewCell()
    }
}

extension CommentsVC: CommentDelegate {
    func commentOptionsTapped(comment: Comment) {
        let alert = UIAlertController(title: "Edit Comment", message: "You can delete or edit.", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Comment", style: .default) { (action) in
            self.firestore.runTransaction({ (transaction, errorPointer) -> Any? in
                
                let talkDocument: DocumentSnapshot
                
                do {
                    try talkDocument = transaction.getDocument(Firestore.firestore().collection(TALKS_REF).document(self.talk.documentId))
                } catch let error as NSError {
                    debugPrint("Fetch Error: \(error.localizedDescription)")
                    return nil
                }
                guard let oldNumComments = talkDocument.data()?[NUM_COMMENTS] as? Int else { return nil }
                
                transaction.updateData([NUM_COMMENTS : oldNumComments - 1 ], forDocument: self.talkRef)
                
                let commentRef = self.firestore.collection(TALKS_REF).document(self.talk.documentId).collection(COMMENTS_REF).document(comment.documentId)
                
                transaction.deleteDocument(commentRef)
                
                return nil
            }) { (object, error) in
                if let error =  error {
                    debugPrint("Transaction Failed: \(error)")
                } else {
                    self.addCommentTxtField.text = ""
                    self.addCommentTxtField.resignFirstResponder()
                }
            }
        }
        let editAction = UIAlertAction(title: "Edit Comment", style: .default) { (action) in
            self.performSegue(withIdentifier: "toUpdateComment", sender: (comment, self.talk))
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UpdateCommentVC {
            if let commentData = sender as? (comment: Comment, talk: Talk) {
                destination.commentData = commentData
            }
        }
    }
}
