//
//  AllDiagnostics.swift
//  AppCovid
//
//  Created by INTERN on 25/05/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore


class AllDiagnostics: UITableViewController {
    
    var arregloDiagnosticos = [Diagnosticos]()
    var arregloNombres = [String]()
    
    var db: Firestore!
    var dbUsuario: [String: Any] = [:]
     var tokens: [UserToken] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title="All diagnostics"
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END FIREBASE setup]
        db = Firestore.firestore()
        
        getDiagnosticos()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arregloDiagnosticos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allDiagnosticsCell", for: indexPath)
        cell.textLabel?.text = arregloNombres[indexPath.row]
        cell.detailTextLabel?.text = arregloDiagnosticos[indexPath.row].fecha
        return cell
    }
    
    func getDiagnosticos() {
            db.collection("users").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.dbUsuario = document.data()
                        let isAdmin = self.dbUsuario["admin"] as? Bool
                        if (!isAdmin!){
                            let name = self.dbUsuario["nombre"] as? String
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
                                        print(diagnostico)
                                        self.arregloDiagnosticos.append(diagnostico)
                                        self.arregloNombres.append(name!)
                                        self.tableView.reloadData()
                                    }
                                }
                            }
//                           self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultDiagnostico" {
            let vistaResultados = segue.destination as! ResultadoDiagnosticoViewController
            let indexPath = tableView.indexPathForSelectedRow!
            print("ESTO QUIERO MANDAR CHITO")
            print(arregloDiagnosticos[indexPath.row])
            vistaResultados.resultado = arregloDiagnosticos[indexPath.row]
        }
    }
    

}
