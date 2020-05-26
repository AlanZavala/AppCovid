//
//  Paciente.swift
//  AppCovid
//
//  Created by INTERN on 25/05/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import UIKit

class Paciente: NSObject {
    var name: String!
    
    var diagnosticos =  [Diagnosticos]()
    
    init(name: String, newDiagnosticos: [Diagnosticos]) {
        self.name = name
        self.diagnosticos = newDiagnosticos
    }
    
    func setDiagnosticos(newDiagnosticos: [Diagnosticos]) -> Void {
        self.diagnosticos = newDiagnosticos
    }
    
    func printDiagnosticos(){
        print(diagnosticos.count)
        print(diagnosticos)
    }
}
