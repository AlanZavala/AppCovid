//
//  ResultadoDiagnosticoViewController.swift
//  AppCovid
//
//  Created by Alan Zavala on 25/05/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import ApiAI
import JSQMessagesViewController
import UIKit
import Speech

import FirebaseCore
import FirebaseFirestore



class ResultadoDiagnosticoViewController: JSQMessagesViewController {
    
    var db: Firestore!
    var dbUsuario: [String: Any] = [:]
    var tokens: [UserToken] = []
    var ref: DocumentReference? = nil
    var messages = [JSQMessage]()
    let currentDate = Date()
    var resultado : Diagnosticos!
//    las lazy var son para que tenga un valor hasta que se use por primera vez
//    en este caso es para definir las burbujas donde va el texto en el chat y el speaker
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    lazy var speechSynthesizer = AVSpeechSynthesizer()

    //MARK: Lifecycle Methods
    override func viewDidLoad()
    {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        
        super.viewDidLoad()
        title = "Resultados de diagnóstico"
        self.senderId = "Id"
        self.senderDisplayName = "Alan"
        self.inputToolbar.contentView.isHidden = true
        // Coloca los mensajes del chatbot pegados a la izquierda (cuando no hay un avatar, si lo hay, se descomentan estas lineas)
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        setResults()

        do {
            let data = try Data.init(contentsOf: dataFileURL())
            tokens = try PropertyListDecoder().decode([UserToken].self, from: data)
            //storedID = tokens.first?.userID
        } catch {
            print("Error al cargar los datos del archivo")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Helper Methods
    
//    se agrega mensaje al array de mensajes y con esto a la colección de mensajes
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //MARK: Gesture Handler Methods
    
    //MARK: Core Functionality
//    func performQuery(senderId:String,name:String,text:String)
//    {
//        let request = ApiAI.shared().textRequest()
//
//
//        // initialize the date formatter and set the style
//        let formatter = DateFormatter()
//        formatter.timeStyle = .medium
//        formatter.dateStyle = .long
//        formatter.locale = .init(identifier: "es_ES")
//
//        // get the date time String from the date object
//
//        if text != "" {
//            request?.query = text
//            if (text == "comenzar" || text == "Comenzar") {
//                ref = db.collection("users").document(tokens.first!.userID).collection("diagnosticos").addDocument(data: [
//                    "preguntas":[],
//                    "respuestas":[],
//                    "fecha": formatter.string(from: currentDate)
//                ])
//            }
//        } else {
//            return
//        }
//
//        request?.setMappedCompletionBlockSuccess({ (request, response) in
//            let response = response as! AIResponse
//            if let textResponse = response.result.fulfillment.speech
//            {
//
//                print(textResponse)
//
//                SpeechManager.shared.speak(text: textResponse)
//                self.addMessage(withId: "BotId", name: "Bot", text: textResponse)
//                self.finishReceivingMessage()
//            }
//        }, failure: { (request, error) in
//            print(error!)
//        })
//        ApiAI.shared().enqueue(request)
//    }
    
    //MARK: JSQMessageViewController Methods
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    //mensaje por parte del usuario
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    //mensaje por parte del sistema/chatbot
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    //obtiene el mensaje, le pone formato y lo pone en la celda correspondiente
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.black
            
        } else {
            
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    //manda el mensaje el usuario
//    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
//
//        addMessage(withId: senderId, name: senderDisplayName!, text: text!)
//        JSQSystemSoundPlayer.jsq_playMessageSentSound()
//
//        finishSendingMessage()
//        //performQuery(senderId: senderId, name: senderDisplayName, text: text!)
//
//    }
    
    func dataFileURL() -> URL {
        let url = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathArchivo = url.appendingPathComponent("Tokens.plist")
        
        return pathArchivo
    }

    func setResults() {
//        for i in 0...resultado.preguntas.count-1 {
//            self.addMessage(withId: "BotId", name: "Bot", text: resultado.preguntas[i])
//            self.finishReceivingMessage()
//        }
        var i = 0
        while i < resultado.preguntas.count || i < resultado.respuestas.count {
            if i < resultado.preguntas.count {
                self.addMessage(withId: "BotId", name: "Bot", text: resultado.preguntas[i])
                self.finishReceivingMessage()
            }
            if i < resultado.respuestas.count {
                addMessage(withId: senderId, name: senderDisplayName!, text: resultado.respuestas[i])
                self.finishReceivingMessage()
            }
            print("estoy en el while iterando")
            i += 1
        }
    }

}

