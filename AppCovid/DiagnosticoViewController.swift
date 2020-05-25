//
//  DiagnosticoViewController.swift
//  AppCovid
//
//  Created by Alan Zavala on 19/04/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import ApiAI
import JSQMessagesViewController
import UIKit
import Speech

import FirebaseCore
import FirebaseFirestore



class DiagnosticoViewController: JSQMessagesViewController {
    
    var db: Firestore!
    var dbUsuario: [String: Any] = [:]
    var tokens: [UserToken] = []
    var ref: DocumentReference? = nil
    var messages = [JSQMessage]()
    let currentDate = Date()
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
        self.senderId = "Id"
        self.senderDisplayName = "Alan"
        self.inputToolbar.contentView.leftBarButtonItem = nil
        // Coloca los mensajes del chatbot pegados a la izquierda (cuando no hay un avatar, si lo hay, se descomentan estas lineas)
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
//        Mensaje de bienvenido con retraso para que se vea más natural
        let deadlineTime = DispatchTime.now() + .milliseconds(700);        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.populateWithWelcomeMessage()
        })
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
    
    func populateWithWelcomeMessage()
    {
        self.addMessage(withId: "BotId", name: "Bot", text: "Buen día, en este apartado puedes realizar un diagnóstico que te ayude a detectar si tienes síntomas e indicios de COVID-19")
        self.finishReceivingMessage()
        self.addMessage(withId: "BotId", name: "Bot", text: "Para empezar el diagnóstico, escribe: comenzar")
        self.finishReceivingMessage()
    }
    
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
    func performQuery(senderId:String,name:String,text:String)
    {
        let request = ApiAI.shared().textRequest()
       

        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        formatter.locale = .init(identifier: "es_ES")

        // get the date time String from the date object
        
        if text != "" {
            request?.query = text
            if (text == "comenzar" || text == "Comenzar") {
                ref = db.collection("users").document(tokens.first!.userID).collection("diagnosticos").addDocument(data: [
                    "preguntas":[],
                    "respuestas":[],
                    "fecha": formatter.string(from: currentDate)
                ])
            }
            else {
                self.uploadMessages(message: text, origin: "User")
            }
        } else {
            return
        }
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            if let textResponse = response.result.fulfillment.speech
            {
               
                print(textResponse)
                self.uploadMessages(message: textResponse, origin: "Bot")
                SpeechManager.shared.speak(text: textResponse)
                self.addMessage(withId: "BotId", name: "Bot", text: textResponse)
                self.finishReceivingMessage()
            }
        }, failure: { (request, error) in
            print(error!)
        })
        ApiAI.shared().enqueue(request)
    }
    
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
            cell.textView?.textColor = UIColor.white
            
        } else {
            
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    //manda el mensaje el usuario
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        addMessage(withId: senderId, name: senderDisplayName!, text: text!)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        performQuery(senderId: senderId, name: senderDisplayName, text: text!)
        
    }
    
    // MARK: DB
    func uploadMessages(message: String, origin: String){
        
        var document = db.collection("users").document(tokens.first!.userID).collection("diagnosticos").document(self.ref!.documentID)
        
        document.getDocument { (document, error) in
            if let document = document, document.exists {
                self.dbUsuario = document.data()!
                var array = [String]()
                
                if origin == "Bot" {
                    array = self.dbUsuario["preguntas"] as! [String]
                    array.append(message)
                    self.db.collection("users").document(self.tokens.first!.userID).collection("diagnosticos").document(document.documentID).setData([ "preguntas": array ], merge: true)
                }
                else {
                    array = self.dbUsuario["respuestas"] as! [String]
                    array.append(message)
                    self.db.collection("users").document(self.tokens.first!.userID).collection("diagnosticos").document(document.documentID).setData([ "respuestas": array ], merge: true)
                }
                        
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func dataFileURL() -> URL {
        let url = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathArchivo = url.appendingPathComponent("Tokens.plist")
        
        return pathArchivo
    }

}
