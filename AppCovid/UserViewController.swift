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

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, protocoloUsuario {
    var tokens: [UserToken] = []
    var db: Firestore!
    @IBOutlet weak var tableView: UITableView!
    var arregloDiagnosticos = [Diagnosticos]()
    let formatter = DateFormatter()
    var dbUsuario: [String: Any] = [:]
    
    // initially set the format based on your datepicker date / server String
//    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    @IBOutlet weak var lblUsername: UILabel!
    
    var theName: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // [START FIREBASE setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END FIREBASE setup]
        db = Firestore.firestore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkUsuario()
    }
    
    func checkUsuario() {
        
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
                        
                        self.lblUsername.text = self.dbUsuario["nombre"] as? String
                        self.theName = self.lblUsername.text
                        
                        if self.dbUsuario["admin"] as? Bool == true {
                            self.performSegue(withIdentifier: "doctorLogin", sender: self)
                        }
                        
                        self.lblUsername.text = self.dbUsuario["nombre"] as? String
                        self.theName = self.lblUsername.text
                        //llamar metodo para diagnosticos
                        self.getDiagnosticos()
                        
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
            "messages": [],
            "admin": false
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
//                ref?.collection("diagnosticos").addDocument(data: [
//                    "preguntas":[],
//                    "respuestas":[]
//                ])
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
        
        cell.textLabel?.text = "Diagnóstico " + arregloDiagnosticos[indexPath.row].fecha
        
        cell.accessoryType = .disclosureIndicator
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
    
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.green
            cell.textLabel?.textColor = UIColor.black
        }
//
//        cell.detailTextLabel?.text = arregloDiagnosticos[indexPath.row].date.description
        return cell
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "callRegistro" {
            let vistaRegistro = segue.destination as! RegistrationViewController
            vistaRegistro.delegado = self
            
        }
        else if segue.identifier == "resultDiagnostico" {
            let vistaResultados = segue.destination as! ResultadoDiagnosticoViewController
            let indexPath = tableView.indexPathForSelectedRow!
            vistaResultados.resultado = arregloDiagnosticos[indexPath.row]
        } else if segue.identifier == "doctorLogin" {
            let doctorView = segue.destination as! DoctorViewController
            doctorView.valueName = theName
        }
    }
    
    //  Obtener diagnosticos
    
    func getDiagnosticos(){
        arregloDiagnosticos = []
        
        db.collection("users").document(tokens.first!.userID).collection("diagnosticos").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    self.dbUsuario = document.data()
                    let preguntas = self.dbUsuario["preguntas"] as! [String]
                    print("Dentro de getDiagnosticos " + preguntas[0])
                    let respuestas = self.dbUsuario["respuestas"] as! [String]
                    let fecha = self.dbUsuario["fecha"] as! String
                    let diagnostico = Diagnosticos(preguntas: preguntas, respuestas: respuestas, fecha: fecha)
                    self.arregloDiagnosticos.append(diagnostico)
                    
                }
                self.tableView.reloadData()
            }
        }
        
    }

}
