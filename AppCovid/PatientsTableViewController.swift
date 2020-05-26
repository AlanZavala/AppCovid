//
//  PatientsTableViewController.swift
//  AppCovid
//
//  Created by INTERN on 25/05/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class PatientsTableViewController: UITableViewController {
    
    var arregloPacientes = [Paciente]()
    
    var db: Firestore!
    var dbUsuario: [String: Any] = [:]
     var tokens: [UserToken] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pacientes"
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END FIREBASE setup]
        db = Firestore.firestore()
        
        getPacientes()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arregloPacientes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pacienteCelda", for: indexPath)
        cell.textLabel?.text = arregloPacientes[indexPath.row].name
        return cell
    }
    
    func getPacientes() {
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.dbUsuario = document.data()
                    let isAdmin = self.dbUsuario["admin"] as? Bool
                    if (!isAdmin!){
                        let name = self.dbUsuario["nombre"] as? String
                        print("El nombre es \(name!)" )
                        var tempDiagnosticos = [Diagnosticos]()
                        self.db.collection("users").document(document.documentID).collection("diagnosticos").getDocuments() {
                            (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for diag in querySnapshot!.documents {
                                    self.dbUsuario = diag.data()
                                    let preguntas = self.dbUsuario["preguntas"] as! [String]
                                    let respuestas = self.dbUsuario["respuestas"] as! [String]
                                    let fecha = self.dbUsuario["fecha"] as! String
                                    let diagnostico = Diagnosticos(preguntas: preguntas, respuestas: respuestas, fecha: fecha)
                                    print("UN DIAGNOSTICO")
                                    print(diagnostico)
                                    tempDiagnosticos.append(diagnostico)
                                }
                                print("FINAL INSERT")
                                print(tempDiagnosticos)
                            }
                        }
                        
                        var d = [Diagnosticos]()
                        let d1 = Diagnosticos(preguntas: ["hola", "hola"], respuestas: ["adios", "adios"], fecha: "2020-20-20")
                        d.append(d1)
      
                        print("CREATE PACIENTE")
                        let newPacient = Paciente(name: name!, newDiagnosticos: d)
//                        let newPacient = Paciente(name: name!, newDiagnosticos: tempDiagnosticos)
                        print(newPacient)
                        self.arregloPacientes.append(newPacient)
                       self.tableView.reloadData()
                    }
                }
            }
        } 
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vista = segue.destination as? DisplayPaciente
        let indice = tableView.indexPathForSelectedRow!
        print("esto voy a pasar")
        print(arregloPacientes[indice.row].name!)
        print(arregloPacientes[indice.row].diagnosticos.count)
        arregloPacientes[indice.row].printDiagnosticos()
        vista?.thePatient = arregloPacientes[indice.row]
    }
    
    
    func dataFileURL() -> URL {
        let url = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathArchivo = url.appendingPathComponent("Tokens.plist")
        
        return pathArchivo
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    
    

}
