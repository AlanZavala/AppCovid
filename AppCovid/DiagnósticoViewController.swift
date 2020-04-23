//
//  DiagnósticoViewController.swift
//  AppCovid
//
//  Created by INTERN on 22/04/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import UIKit

struct Diagnos {
    var nombre: String!
    // structure definition goes here
    var date: Date
}


class Diagno_sticoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var arregloDiagnosticos = [Diagnos]()
    
    let formatter = DateFormatter()
    // initially set the format based on your datepicker date / server String
//    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dia1 = Diagnos(nombre: "resfriado", date: Date())
        
        
        
        arregloDiagnosticos += [dia1]
        
        print(arregloDiagnosticos.count)
        
        

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arregloDiagnosticos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaDiagnóstico", for: indexPath)
        
        cell.textLabel?.text = arregloDiagnosticos[indexPath.row].nombre
        
        cell.detailTextLabel?.text = arregloDiagnosticos[indexPath.row].date.description
        return cell
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
