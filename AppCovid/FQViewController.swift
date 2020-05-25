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



class FQViewController: JSQMessagesViewController {
    
    var db: Firestore!
    var dbUsuario: [String: Any] = [:]
    
    var messages = [JSQMessage]()
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Helper Methods
    
    func populateWithWelcomeMessage()
    {
        self.addMessage(withId: "BotId", name: "Bot", text: "Qué tal soy un sistema inteligente que intentará aclarar tus dudas en relación con el coronavirus.")
        self.finishReceivingMessage()
        self.addMessage(withId: "BotId", name: "Bot", text: "Me puedes preguntar sobre: \n ¿Qué es el coronavirus?\n¿Qué es el covid19?\n¿Qué es el COVID 19?\n¿Los síntomas?\n¿Como se propaga COVID 19?\n¿Se trasmite por el aire?\n¿Qué puedo hacer para prevenir la enfermedad?\nHazme tus preguntas de forma natural e intentare con mi limitada Inteligencia Artificial contestarte.")
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
        if text != "" {
            request?.query = text
        } else {
            return
        }
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            if let textResponse = response.result.fulfillment.speech
            {
                print("hola print")
                print(textResponse)
                self.uploadMessages(message: textResponse)
                print("adios print")
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
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            
            return outgoingBubbleImageView
        } else { // 3
            
            return incomingBubbleImageView
        }
    }
    
    //removing avatars
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
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
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        addMessage(withId: senderId, name: senderDisplayName!, text: text!)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        performQuery(senderId: senderId, name: senderDisplayName, text: text!)
        
    }
    
    
    
    // MARK: DB
    func uploadMessages(message: String){
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
                        
                        var array = [String]()
                        
                        array = self.dbUsuario["messages"] as! [String]
                        
                        print("the array")
                        print(array)
                        
                        array.append(message)
                        
                        self.db.collection("users").document(document.documentID).setData([ "messages": array ], merge: true)
                        
                    }
                }
                
                
            }
        }
    }
    
    func dataFileURL() -> URL {
        let url = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathArchivo = url.appendingPathComponent("Tokens.plist")
        
        return pathArchivo
    }

}
