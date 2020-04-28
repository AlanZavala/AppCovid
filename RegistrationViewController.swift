//
//  RegistrationViewController.swift
//  AppCovid
//
//  Created by user168611 on 4/27/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import UIKit

import FirebaseCore
import FirebaseFirestore

protocol protocoloUsuario {
    func registerUser(newUsername: String) -> Void
}

class RegistrationViewController: UIViewController {

    var db: Firestore!
    @IBOutlet weak var tfUsername: UITextField!
    var delegado: protocoloUsuario!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }
    
    @IBAction func registerUser(_ sender: Any) {
        if tfUsername.text != "" {
            delegado.registerUser(newUsername: tfUsername.text!)
            dismiss(animated: true, completion: nil)
            navigationController?.popViewController(animated: true) 
        }
    }

}
