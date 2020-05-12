//
//  DiagnósticoViewController.swift
//  AppCovid
//
//  Created by INTERN on 22/04/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import UIKit

import FirebaseCore
import FirebaseFirestore

struct Diagnos {
    var nombre: String!
    // structure definition goes here
    var date: Date
}

class Diagno_sticoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, protocoloUsuario {
    
    var db: Firestore!
    var arregloDiagnosticos = [Diagnos]()
    let formatter = DateFormatter()
    var dbUsuario: [String: Any] = [:]
    // initially set the format based on your datepicker date / server String
//    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    @IBOutlet weak var lblUsername: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dia1 = Diagnos(nombre: "resfriado", date: Date())
        arregloDiagnosticos += [dia1]
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkUsuario()
    }
    
    func checkUsuario() {
        let tokens: [UserToken]
        var storedID:String? = ""
        do {
            let data = try Data.init(contentsOf: dataFileURL())
            tokens = try PropertyListDecoder().decode([UserToken].self, from: data)
            storedID = tokens.first?.userID
        } catch {
            print("Error al cargar los datos del archivo")
        }
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if document.documentID == storedID {
                        self.dbUsuario = document.data()
                        
                        if self.dbUsuario["admin"] as? Bool == true {
                            self.performSegue(withIdentifier: "doctorLogin", sender: self)
                        }
                        
                        self.lblUsername.text = self.dbUsuario["nombre"] as? String
                    }
                }
                
                if self.lblUsername.text == "" {
                    self.performSegue(withIdentifier: "callRegistro", sender: self)
                }
            }
        }
    }
    
    func registerUser(newUsername: String) {
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "nombre": newUsername,
            "diagnosticos": [],
            "admin": false
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.saveUserID(username: newUsername, userID: ref!.documentID)
                self.checkUsuario()
            }
        }
    }
    
    @IBAction func saveUserID(username: String, userID: String) {
        let token = [UserToken(username: username, userID: userID)]
        do {
            let data = try PropertyListEncoder().encode(token)
            try data.write(to: dataFileURL())
            presentingViewController?.dismiss(animated: true, completion: nil)
        } catch {
            print("Error al guardar los datos")
        }
    }
    
    func dataFileURL() -> URL {
        let url = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathArchivo = url.appendingPathComponent("Tokens.plist")
        
        return pathArchivo
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "callRegistro" {
            let vistaRegistro = segue.destination as! RegistrationViewController
            vistaRegistro.delegado = self
        }
    }

}
