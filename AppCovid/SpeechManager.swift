//
//  SpeechManager.swift
//  AppCovid
//
//  Created by Alan Zavala on 19/04/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import Foundation
import Speech

protocol SpeechManagerDelegate
{
    func didReceiveText(text:String)
    func didStartedListening(status:Bool)
}

class SpeechManager
{
    let speechSynthesizer = AVSpeechSynthesizer()
    var delegate:SpeechManagerDelegate?
//    esto servirá si queremos que pueda dictar el usuario el texto
    static let shared:SpeechManager = {
        let instance = SpeechManager()
        return instance
    }()
    
    func speak(text: String) {

        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        speechSynthesizer.speak(speechUtterance)
    }
}
