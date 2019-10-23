//
//  AddTalkVC.swift
//  iTalk
//
//  Created by Mahmoud Elshakoushy on 10/19/19.
//  Copyright © 2019 Mahmoud Elshakoushy. All rights reserved.
//

import UIKit
import Firebase

class AddTalkVC: UIViewController, UITextViewDelegate {

    //Outlets
    @IBOutlet private weak var postBtn: UIButton!
    @IBOutlet private weak var talkTxt: UITextView!
    @IBOutlet private weak var userNameTxt: UITextField!
    @IBOutlet private weak var segmentedCategories: UISegmentedControl!
  
    //Variables
    private var selectedCategory = TalkCategory.funny.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postBtn.layer.cornerRadius = 4
        userNameTxt.layer.cornerRadius = 4
        talkTxt.text = "My random talk!"
        talkTxt.textColor = UIColor.lightGray
        talkTxt.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        talkTxt.text = ""
        talkTxt.textColor = UIColor.darkGray
    }
    
    @IBAction func postBtnPressed(_ sender: Any) {
        guard let username = userNameTxt.text else { return}
        Firestore.firestore().collection(TALKS_REF).addDocument(data: [
            CATEGORY : selectedCategory,
            NUM_COMMENTS : 0,
            NUM_LIKES : 0,
            TALK_TXT : talkTxt.text,
            TIMESTAMP : FieldValue.serverTimestamp(),
            USERNAME : username,
            USER_ID : Auth.auth().currentUser?.uid ?? ""
        ]) { (err) in
            if let err = err {
                debugPrint("Error adding documents: \(err)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func categoriesChanged(_ sender: Any) {
        switch segmentedCategories.selectedSegmentIndex {
        case 0:
            selectedCategory = TalkCategory.funny.rawValue
        case 1:
            selectedCategory = TalkCategory.serious.rawValue
        default:
            selectedCategory = TalkCategory.crazy.rawValue
        }
    }
    
}
