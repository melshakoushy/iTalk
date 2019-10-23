//
//  ViewController.swift
//  iTalk
//
//  Created by Mahmoud Elshakoushy on 10/18/19.
//  Copyright © 2019 Mahmoud Elshakoushy. All rights reserved.
//

import UIKit
import Firebase


class MainVC: UIViewController {
    
    // outlets
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView!
    
    // Variables
    private var talks = [Talk]()
    private var collectionRef: CollectionReference!
    private var talksListener: ListenerRegistration!
    private var selectedCategory = TalkCategory.funny.rawValue
    private var handle : AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        collectionRef = Firestore.firestore().collection(TALKS_REF)
    }
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener( { (auth, user) in
            if user == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
                self.present(loginVC, animated: true, completion: nil)
            } else {
                self.setListener()
            }
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        if talksListener != nil {
            talksListener.remove()
        }
    }
    
    @IBAction func categoryChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            selectedCategory = TalkCategory.funny.rawValue
        case 1:
            selectedCategory = TalkCategory.serious.rawValue
        case 2:
            selectedCategory = TalkCategory.crazy.rawValue
        default:
            selectedCategory = TalkCategory.popular.rawValue
        }
        talksListener.remove()
        setListener()
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            debugPrint("Error in signing out: \(signOutError)")
        }
    }
    
    func setListener() {
        if selectedCategory == TalkCategory.popular.rawValue {
            talksListener = collectionRef
                .order(by: NUM_LIKES, descending: true)
                .addSnapshotListener { (snapshot, error) in
                    if let err = error {
                        debugPrint("\(err)")
                    } else {
                        self.talks.removeAll()
                        self.talks = Talk.parseData(snapshot: snapshot)
                        self.tableView.reloadData()
                    }
            }
        } else {
            talksListener = collectionRef
                .whereField(CATEGORY, isEqualTo: selectedCategory)
                .order(by: TIMESTAMP, descending: true)
                .addSnapshotListener { (snapshot, error) in
                    if let err = error {
                        debugPrint("\(err)")
                    } else {
                        self.talks.removeAll()
                        self.talks = Talk.parseData(snapshot: snapshot)
                        self.tableView.reloadData()
                    }
            }
        }
    }
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "talkCell", for: indexPath) as? TalkCell {
            cell.configureCell(talk: talks[indexPath.row], delegate: self)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toComments", sender: talks[indexPath.row])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            if let destinationVC = segue.destination as? CommentsVC {
                if let talk = sender as? Talk {
                    destinationVC.talk = talk
                }
            }
        }
    }
}

extension MainVC: TalkDelegate {
    func talkOptiosTapped(talk: Talk) {
        
    }
}
