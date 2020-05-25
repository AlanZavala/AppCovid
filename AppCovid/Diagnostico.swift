//
//  Diagnostico.swift
//  AppCovid
//
//  Created by INTERN on 22/04/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import UIKit

class Diagnosticos: NSObject {

    var preguntas = [String]()
    var respuestas = [String]()
    var fecha: String!
    init(preguntas: [String], respuestas: [String], fecha: String) {
        self.preguntas = preguntas
        self.respuestas = respuestas
        self.fecha = fecha
    }

}
