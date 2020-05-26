//
//  DisplayPaciente.swift
//  AppCovid
//
//  Created by INTERN on 25/05/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import UIKit

class DisplayPaciente: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var thePatient: Paciente!
    
    var arregloDiagnosticos = [Diagnosticos]()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        lbName.text = thePatient.name
        arregloDiagnosticos = thePatient.diagnosticos
        print(thePatient.diagnosticos.count)
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arregloDiagnosticos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pacienteCelda", for: indexPath)
        cell.textLabel?.text = "Diagnóstico " + arregloDiagnosticos[indexPath.row].fecha
        cell.accessoryType = .disclosureIndicator
//        cell.backgroundColor = UIColor.link
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 255, alpha: 1)
            
        return cell
    }
    


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultDiagnostico" {
            let vistaResultados = segue.destination as! ResultadoDiagnosticoViewController
            let indexPath = tableView.indexPathForSelectedRow!
            vistaResultados.resultado = arregloDiagnosticos[indexPath.row]
        }
    }
    

}
