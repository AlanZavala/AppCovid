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
    
    var arregloDiagnosticos = [Diagnosticos]()
     var arregloNombres = [String]()
    
    var db: Firestore!
    var dbUsuario: [String: Any] = [:]
     var tokens: [UserToken] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PACIENTES"
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END FIREBASE setup]
        db = Firestore.firestore()
        
//        getPacientes()
        getDiagnosticos()
        
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
         orderPacientes()
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
        cell.accessoryType = .disclosureIndicator
        
        cell.layer.cornerRadius = 10
        
        cell.imageView?.image = UIImage(named: "usuario")
        
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = UIColor.link
            cell.textLabel?.textColor = UIColor.white
        } 
        return cell
        
    }
    
    func find(value searchValue: String, in array: [Paciente]) -> Int {
        
        print("VOY A BUSCAR \(searchValue)")
        
        for (index, value) in array.enumerated()
        {
            print(value.name!)
            if value.name == searchValue {
                print("lo encontre")
//                print(value.name!)
//                print(searchValue)
                return index
            }
        }
        print("no lo encontre")
        return -1
    }
    
    func orderPacientes(){
       
//        print("orderPacitente")
//
//        print(arregloDiagnosticos)
//        print(arregloNombres)
        arregloPacientes.removeAll()
            var newPatient: Paciente
            for i in 1 ..< arregloNombres.count {
//                print("DEBUG")
                let index: Int = find(value: arregloNombres[i], in: arregloPacientes)
//                print("index is: ")
                print("index is \(index)")
                if (index == -1) {
                    print("Es nuevo")
                    newPatient = Paciente(name: arregloNombres[i], newDiagnosticos: [arregloDiagnosticos[i]])
                    arregloPacientes.append(newPatient)
                }else {
                    
                    var tempDiagnosticos = arregloPacientes[index].diagnosticos
                    tempDiagnosticos.append(arregloDiagnosticos[i])
                    print("este el nombre appren \(arregloNombres[index])")
                    newPatient = Paciente(name: arregloNombres[i], newDiagnosticos: tempDiagnosticos)
                    arregloPacientes[index] = newPatient
                    print("APPEND")

                }
            }
//            print("EL ARREGLO DE PACIENTES ES: ")
//            print(arregloPacientes.count)
            self.tableView.reloadData()
        
//        print("YEAH")
        
    }
    
    func getDiagnosticos() {
        arregloDiagnosticos.removeAll()
        arregloNombres.removeAll()
//         print("getDiagnosticso")
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.dbUsuario = document.data()
                        let name = self.dbUsuario["nombre"] as? String
//                        print("El numero  de documentos es \(document.documentID)")
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
//                                    print(diagnostico)
                                    self.arregloDiagnosticos.append(diagnostico)
                                    self.arregloNombres.append(name!)
//                                    print("ARREGLOS DIAGNOSTICOS")
//                                    print(self.arregloDiagnosticos)
//                                    print("ARREGLO NOMBRES")
//                                    print(self.arregloNombres)
                                }
                            }
                        }
                }
            }
        }
    }
    
    
    func getPacientes() {
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.dbUsuario = document.data()
                    
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
