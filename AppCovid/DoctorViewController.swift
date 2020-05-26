//
//  DoctorViewController.swift
//  AppCovid
//
//  Created by user168611 on 5/11/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import UIKit

class DoctorViewController: UIViewController {
        
    @IBOutlet weak var theName: UILabel!
    var valueName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        theName.text = valueName
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
