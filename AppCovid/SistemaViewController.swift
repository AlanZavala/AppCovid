//
//  SistemaViewController.swift
//  AppCovid
//
//  Created by INTERN on 22/04/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import UIKit

class SistemaViewController: UIViewController {
    
    var isActive: Bool!
    
    @IBOutlet weak var botonBackGround: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        isActive = true
        setImage()
    }
    
    
    func setImage () {
        var image: UIImage!
        
        if isActive {
            image = UIImage(named: "audioON")
            
        } else {
            image = UIImage(named: "audioOFf")
        }
        botonBackGround.setImage(image, for: .normal)
    }
    
    @IBAction func UpdateVolume(_ sender: UIButton) {
        isActive = !isActive
        setImage()
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
